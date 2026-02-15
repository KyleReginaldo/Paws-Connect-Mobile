import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart' hide ButtonStyle;
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/components/media/network_image_view.dart';
import 'package:paws_connect/core/extension/ext.dart';
import 'package:paws_connect/core/widgets/text.dart';
import 'package:paws_connect/core/widgets/text_field.dart';
import 'package:paws_connect/features/donation/provider/direct_donation_provider.dart';
import 'package:paws_connect/features/payment/services/payment_text_extractor.dart';
import 'package:paws_connect/features/profile/repository/profile_repository.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart'
    show StepItem, Steps, TextArea, RefreshTrigger;

import '../../../core/services/loading_service.dart';
import '../../../core/supabase/client.dart';
import '../../../core/theme/paws_theme.dart';
import '../../../core/widgets/button.dart';
import '../../../dependency.dart';
import '../../fundraising/repository/fundraising_repository.dart';

@RoutePage()
class PaymentScreen extends StatefulWidget implements AutoRouteWrapper {
  final int fundraisingId;
  const PaymentScreen({
    super.key,
    @PathParam('id') required this.fundraisingId,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sl<ProfileRepository>()),
        ChangeNotifierProvider.value(value: sl<FundraisingRepository>()),
      ],
      child: this,
    );
  }
}

class _PaymentScreenState extends State<PaymentScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToBottom = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    // Add listener to referenceNumber controller to update UI when text changes
    referenceNumber.addListener(() {
      setState(() {
        // This will trigger a rebuild when the reference number changes
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProfileRepository>().fetchUserProfile(USER_ID ?? "");
      context.read<FundraisingRepository>().fetchFundraisingById(
        widget.fundraisingId,
      );
    });
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      final maxScrollExtent = _scrollController.position.maxScrollExtent;
      final currentScrollPosition = _scrollController.offset;

      final isAtTop = currentScrollPosition <= 100;
      final isAtBottom = currentScrollPosition >= (maxScrollExtent - 100);

      setState(() {
        if (isAtTop) {
          _showScrollToBottom = true;
        } else if (isAtBottom) {
          _showScrollToBottom = false;
        }
      });
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  final amount = TextEditingController();
  final message = TextEditingController();
  final referenceNumber = TextEditingController();
  final formKey = GlobalKey<FormState>();
  XFile? _screenshotImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    amount.dispose();
    message.dispose();
    referenceNumber.dispose();
    super.dispose();
  }

  Future<bool> isAnonymous() async {
    bool? anonymous = await showDialog<bool?>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: PawsText('Anonymous'),
          content: PawsText('Do you want to make this donation anonymous?'),
          actions: [
            PawsTextButton(
              label: 'No',
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            PawsTextButton(
              label: 'Yes',
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
    return anonymous ?? false;
  }

  void handleDonation() async {
    if (!formKey.currentState!.validate()) return;
    final anonymous = await isAnonymous();
    if (_screenshotImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a screenshot of your GCash payment'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    try {
      final result = await LoadingService.showWhileExecuting(
        context,
        DirectDonationProvider().createDirectDonation(
          donor: USER_ID ?? "",
          amount: int.parse(amount.text),
          fundraising: widget.fundraisingId,
          message: message.text.trim(),
          referenceNumber: referenceNumber.text.trim(),
          screenshot: _screenshotImage!,
          isAnonymous: anonymous,
        ),
        message: 'Submitting donation...',
      );

      if (result.isError) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(result.error)));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(result.value)));
        }

        amount.clear();
        message.clear();
        referenceNumber.clear();
        setState(() {
          _screenshotImage = null;
        });

        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit donation')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        await _processImageWithTextExtraction(image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image != null) {
        await _processImageWithTextExtraction(image);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to take photo: $e')));
      }
    }
  }

  Future<void> _processImageWithTextExtraction(XFile image) async {
    setState(() {
      _screenshotImage = image;
    });

    try {
      final paymentData = await LoadingService.showWhileExecuting(
        context,
        PaymentTextExtractor.extractPaymentData(image),
        message: 'Analyzing image...',
      );

      if (paymentData.success) {
        debugPrint('Extracted payment data: $paymentData');

        // Update controllers and trigger rebuild
        setState(() {
          referenceNumber.text = paymentData.referenceNumber;
          debugPrint('Updated reference number: ${referenceNumber.text}');
          amount.text = paymentData.amount;
          debugPrint('Updated amount: ${amount.text}');
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment details extracted!')),
          );
        }

        _showExtractedDataDialog(paymentData);
      } else {
        debugPrint('Text extraction failed: ${paymentData.error}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Could not extract payment details automatically. Please fill manually.',
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error in text extraction: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to analyze image: $e')));
      }
    }
  }

  void _showExtractedDataDialog(PaymentData paymentData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Extracted Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (paymentData.referenceNumber.isNotEmpty) ...[
              Text('Reference: ${paymentData.referenceNumber}'),
              const SizedBox(height: 8),
            ],
            if (paymentData.amount.isNotEmpty) ...[
              Text('Amount: ₱${paymentData.amount}'),
              const SizedBox(height: 8),
            ],
            const Text('Please verify the extracted data is correct.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  List<(String, String)> supportedApps = [
    ('com.globe.gcash.android', 'gcash'),
    ('com.paymaya', 'maya'),
    ('ph.com.gotyme', 'gotyme'),
  ];

  Future<List<(String, AppInfo)>> _getInstalledSupportedApps() async {
    final List<(String, AppInfo)> installed = [];
    for (final pkg in supportedApps) {
      try {
        AppInfo? info = await InstalledApps.getAppInfo(
          pkg.$1,
          BuiltWith.native_or_others,
        );

        if (info != null) installed.add((pkg.$2, info));
      } catch (_) {
        // Ignore failures for individual packages
      }
    }
    return installed;
  }

  Future<void> _startApp(AppInfo app) async {
    try {
      InstalledApps.startApp(app.packageName);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to open ${app.name}')));
      }
    }
  }

  Future<void> openPaymentApp() async {
    final apps = await _getInstalledSupportedApps();
    if (!mounted) return;
    if (apps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No supported payment apps installed (GCash, Maya, GoTyme).',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (apps.length == 1) {
      await _startApp(apps.first.$2);
      return;
    }

    // Let the user choose which app to open
    if (!mounted) return;
    final chosen = await showDialog<AppInfo>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(),
        backgroundColor: Colors.white,
        title: const PawsText('Open payment app', fontSize: 15),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: apps.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final a = apps[i];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/${a.$1}.jpeg',
                    width: 32,
                    height: 32,
                  ),
                ),
                title: Text(a.$2.name),
                subtitle: Text('Open ${a.$2.name} app'),
                onTap: () => Navigator.of(ctx).pop(a.$2),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (chosen != null) {
      await _startApp(chosen);
    }
  }

  Future<void> openGCashApp() async {
    AppInfo? app = await InstalledApps.getAppInfo(
      'com.paymaya',
      BuiltWith.native_or_others,
    );
    if (app != null) {
      InstalledApps.startApp(app.packageName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fundraising = context.watch<FundraisingRepository>().fundraising;
    debugPrint('qrcode: ${fundraising?.qrCode}');
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Payment',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: PawsColors.textPrimary,
            ),
          ),
        ),
        body: RefreshTrigger(
          onRefresh: () async {
            context.read<ProfileRepository>().fetchUserProfile(USER_ID ?? "");
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: PawsColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PawsText(
                              'Payment Options',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            PawsText(
                              'Choose any of the payment methods below',
                              fontSize: 13,
                              color: PawsColors.textSecondary,
                            ),
                          ],
                        ),
                        SizedBox(height: 16),

                        // New E-Wallets Section
                        if (fundraising?.eWallets != null &&
                            fundraising!.eWallets!.isNotEmpty) ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    LucideIcons.smartphone,
                                    size: 16,
                                    color: PawsColors.primary,
                                  ),
                                  SizedBox(width: 8),
                                  PawsText(
                                    'E-Wallets',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: PawsColors.primary,
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              ...fundraising.eWallets!.map(
                                (paymentInfo) => Container(
                                  margin: EdgeInsets.only(bottom: 12),
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: PawsColors.surface,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: PawsColors.border.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: PawsColors.primary
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: PawsText(
                                              paymentInfo.label,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: PawsColors.primary,
                                            ),
                                          ),
                                          Spacer(),
                                          if (paymentInfo
                                              .accountNumber
                                              .isNotEmpty)
                                            IconButton(
                                              onPressed: () {
                                                Clipboard.setData(
                                                  ClipboardData(
                                                    text: paymentInfo
                                                        .accountNumber,
                                                  ),
                                                );
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Account number copied to clipboard!',
                                                    ),
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                  ),
                                                );
                                              },
                                              icon: Icon(
                                                LucideIcons.copy,
                                                size: 16,
                                                color: PawsColors.primary,
                                              ),
                                              style: IconButton.styleFrom(
                                                backgroundColor: PawsColors
                                                    .primary
                                                    .withValues(alpha: 0.1),
                                                foregroundColor:
                                                    PawsColors.primary,
                                                padding: EdgeInsets.all(8),
                                                minimumSize: Size(32, 32),
                                              ),
                                            ),
                                        ],
                                      ),
                                      if (paymentInfo
                                          .accountNumber
                                          .isNotEmpty) ...[
                                        SizedBox(height: 8),
                                        PawsText(
                                          'Account: ${paymentInfo.accountNumber}',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ],
                                      if (paymentInfo.qrCode != null &&
                                          paymentInfo.qrCode!.isNotEmpty) ...[
                                        SizedBox(height: 8),
                                        Center(
                                          child: Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: PawsColors.border,
                                              ),
                                            ),
                                            child: NetworkImageView(
                                              paymentInfo.qrCode!.startsWith(
                                                    'https',
                                                  )
                                                  ? paymentInfo.qrCode!
                                                  : paymentInfo
                                                        .qrCode!
                                                        .transformedUrl,
                                              height: 120,
                                              width: 120,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Center(
                                          child: PawsText(
                                            'Scan QR code with ${paymentInfo.label}',
                                            fontSize: 11,
                                            color: PawsColors.textSecondary,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        // New Bank Accounts Section
                        if (fundraising?.bankAccounts != null &&
                            fundraising!.bankAccounts!.isNotEmpty) ...[
                          if (fundraising.eWallets != null &&
                              fundraising.eWallets!.isNotEmpty)
                            SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    LucideIcons.building,
                                    size: 16,
                                    color: PawsColors.primary,
                                  ),
                                  SizedBox(width: 8),
                                  PawsText(
                                    'Bank Accounts',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: PawsColors.primary,
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              ...fundraising.bankAccounts!.map(
                                (paymentInfo) => Container(
                                  margin: EdgeInsets.only(bottom: 12),
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: PawsColors.surface,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: PawsColors.border.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: PawsColors.primary
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: PawsText(
                                              paymentInfo.label,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: PawsColors.primary,
                                            ),
                                          ),
                                          Spacer(),
                                          if (paymentInfo
                                              .accountNumber
                                              .isNotEmpty)
                                            IconButton(
                                              onPressed: () {
                                                Clipboard.setData(
                                                  ClipboardData(
                                                    text: paymentInfo
                                                        .accountNumber,
                                                  ),
                                                );
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Account number copied to clipboard!',
                                                    ),
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                  ),
                                                );
                                              },
                                              icon: Icon(
                                                LucideIcons.copy,
                                                size: 16,
                                                color: PawsColors.primary,
                                              ),
                                              style: IconButton.styleFrom(
                                                backgroundColor: PawsColors
                                                    .primary
                                                    .withValues(alpha: 0.1),
                                                foregroundColor:
                                                    PawsColors.primary,
                                                padding: EdgeInsets.all(8),
                                                minimumSize: Size(32, 32),
                                              ),
                                            ),
                                        ],
                                      ),
                                      if (paymentInfo
                                          .accountNumber
                                          .isNotEmpty) ...[
                                        SizedBox(height: 8),
                                        PawsText(
                                          'Account: ${paymentInfo.accountNumber}',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ],
                                      if (paymentInfo.qrCode != null &&
                                          paymentInfo.qrCode!.isNotEmpty) ...[
                                        SizedBox(height: 8),
                                        Center(
                                          child: Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: PawsColors.border,
                                              ),
                                            ),
                                            child: NetworkImageView(
                                              paymentInfo.qrCode!.startsWith(
                                                    'https',
                                                  )
                                                  ? paymentInfo.qrCode!
                                                  : paymentInfo
                                                        .qrCode!
                                                        .transformedUrl,
                                              height: 120,
                                              width: 120,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Center(
                                          child: PawsText(
                                            'Scan QR code for ${paymentInfo.label}',
                                            fontSize: 11,
                                            color: PawsColors.textSecondary,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        // Fallback to old GCash format if no new payment methods
                        if ((fundraising?.eWallets == null ||
                                fundraising!.eWallets!.isEmpty) &&
                            (fundraising?.bankAccounts == null ||
                                fundraising!.bankAccounts!.isEmpty) &&
                            (fundraising?.gcashNumber != null ||
                                fundraising?.qrCode != null)) ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PawsText(
                                'GCash Payment',
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                              PawsText(
                                'Send your donation to the details below',
                                fontSize: 13,
                                color: PawsColors.textSecondary,
                              ),
                              SizedBox(height: 16),

                              if (fundraising?.gcashNumber != null) ...[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          LucideIcons.phone,
                                          size: 16,
                                          color: PawsColors.primary,
                                        ),
                                        SizedBox(width: 8),
                                        PawsText(
                                          'GCash Number',
                                          fontSize: 14,
                                          color: PawsColors.primary,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: PawsText(
                                            fundraising!.gcashNumber!,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: PawsColors.textPrimary,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            Clipboard.setData(
                                              ClipboardData(
                                                text: fundraising.gcashNumber!,
                                              ),
                                            );
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Copied to clipboard!',
                                                ),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                              ),
                                            );
                                          },
                                          icon: Icon(
                                            LucideIcons.copy,
                                            size: 20,
                                            color: PawsColors.primary,
                                          ),
                                          style: IconButton.styleFrom(
                                            backgroundColor: PawsColors.primary
                                                .withValues(alpha: 0.1),
                                            foregroundColor: PawsColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                              ],

                              if (fundraising?.qrCode != null) ...[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          LucideIcons.qrCode,
                                          size: 16,
                                          color: PawsColors.primary,
                                        ),
                                        SizedBox(width: 8),
                                        PawsText(
                                          'QR Code',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: PawsColors.primary,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    Center(
                                      child: Container(
                                        padding: EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: PawsColors.border,
                                          ),
                                        ),
                                        child: NetworkImageView(
                                          fundraising!.transformedQrCode!,
                                          height: 180,
                                          width: 180,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Center(
                                      child: PawsText(
                                        'Scan this QR code with your GCash app',
                                        fontSize: 12,
                                        color: PawsColors.textSecondary,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: PawsColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              LucideIcons.listChecks,
                              color: PawsColors.primary,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            PawsText(
                              'How to Send Payment',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Steps(
                          children: [
                            StepItem(
                              title: Text(
                                'Choose a payment method',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              content: [
                                Text(
                                  'Select from the available payment options above.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: PawsColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            StepItem(
                              title: Text(
                                'Open your payment app',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              content: [
                                Text(
                                  'Launch the app corresponding to your chosen payment method.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: PawsColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            StepItem(
                              title: Text(
                                'Send money or Scan QR',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              content: [
                                Text(
                                  'Scan the QR code or use the account number provided.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: PawsColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            StepItem(
                              title: Text(
                                'Enter amount and send',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              content: [
                                Text(
                                  'Enter your donation amount and complete the payment.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: PawsColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            StepItem(
                              title: Text(
                                'Take a screenshot',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              content: [
                                Text(
                                  'Capture the payment confirmation screen and upload it below.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: PawsColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),
                  PawsText(
                    'Upload payment confirmation screenshot below',
                    fontSize: 16,
                    color: PawsColors.textSecondary,
                  ),
                  SizedBox(height: 16),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          PawsText(
                            'Payment Screenshot',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          SizedBox(width: 8),
                          Icon(
                            LucideIcons.sparkles,
                            size: 16,
                            color: PawsColors.primary,
                          ),
                          SizedBox(width: 4),
                          PawsText(
                            'Smart detection',
                            fontSize: 12,
                            color: PawsColors.primary,
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      PawsText(
                        'Upload a clear screenshot of your payment confirmation',
                        fontSize: 12,
                        color: PawsColors.textSecondary,
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(12),
                        width: double.infinity,
                        height: _screenshotImage != null ? 200 : null,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: PawsColors.border,
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _screenshotImage != null
                            ? Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      File(_screenshotImage!.path),
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _screenshotImage = null;
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    LucideIcons.image,
                                    size: 40,
                                    color: PawsColors.textSecondary,
                                  ),
                                  SizedBox(height: 8),
                                  PawsText(
                                    'Upload payment screenshot',
                                    color: PawsColors.textSecondary,
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    spacing: 12,
                                    children: [
                                      PawsTextButton(
                                        label: 'Camera',
                                        icon: LucideIcons.camera,
                                        onPressed: _takePhoto,
                                      ),
                                      PawsTextButton(
                                        label: 'Gallery',
                                        icon: LucideIcons.image,
                                        onPressed: _pickImage,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  PawsTextField(
                    hint: 'Amount',
                    label: 'Amount',
                    controller: amount,
                    prefixIcon: PawsTextButton(
                      label: '₱',
                      padding: EdgeInsets.zero,
                      foregroundColor: PawsColors.textSecondary,
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      final intValue = double.tryParse(value);
                      if (intValue == null) {
                        return 'Please enter a valid number';
                      }
                      final remaining =
                          (fundraising?.targetAmount ?? 0) -
                          (fundraising?.raisedAmount ?? 0);

                      if (intValue > remaining) {
                        return 'Amount exceeds remaining target amount of ${remaining.displayMoney()}';
                      }
                      if (intValue < 10) {
                        return 'Minimum amount is ₱10.00';
                      }

                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  PawsTextField(
                    hint: 'Reference Number',
                    label: 'Reference Number',
                    controller: referenceNumber,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the reference number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextArea(
                    placeholder: PawsText('Message (optional)'),
                    controller: message,
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showScrollToBottom ? _scrollToBottom : _scrollToTop,
          backgroundColor: PawsColors.primary,
          foregroundColor: Colors.white,
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 400),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return RotationTransition(
                turns: animation,
                child: FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                ),
              );
            },
            child: Icon(
              _showScrollToBottom ? LucideIcons.arrowDown : LucideIcons.arrowUp,
              key: ValueKey(_showScrollToBottom),
              size: 24,
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.all(16).copyWith(bottom: 24),
          child: PawsElevatedButton(
            label: referenceNumber.text.isEmpty
                ? 'Open Payment App'
                : 'Submit Donation',
            onPressed: () {
              if (referenceNumber.text.isEmpty) {
                openPaymentApp();
              } else {
                handleDonation();
              }
            },
          ),
        ),
      ),
    );
  }
}
