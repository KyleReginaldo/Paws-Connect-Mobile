// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart' hide ButtonStyle;
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/components/media/network_image_view.dart';
import 'package:paws_connect/core/extension/int.ext.dart';
import 'package:paws_connect/core/widgets/text.dart';
import 'package:paws_connect/core/widgets/text_field.dart';
import 'package:paws_connect/features/donation/provider/direct_donation_provider.dart';
import 'package:paws_connect/features/payment/services/payment_text_extractor.dart';
import 'package:paws_connect/features/profile/repository/profile_repository.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart'
    show StepItem, Steps, TextArea;

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

      // If we're close to the top (within 100 pixels), show scroll to bottom
      // If we're close to the bottom (within 100 pixels), show scroll to top
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

  void handleDonation() async {
    if (!formKey.currentState!.validate()) return;

    if (_screenshotImage == null) {
      EasyLoading.showError('Please upload a screenshot of your GCash payment');
      return;
    }

    EasyLoading.show(status: 'Submitting donation...');

    final result = await DirectDonationProvider().createDirectDonation(
      donor: USER_ID ?? "",
      amount: int.parse(amount.text),
      fundraising: widget.fundraisingId,
      message: message.text.trim(),
      referenceNumber: referenceNumber.text.trim(),
      screenshot: _screenshotImage!,
    );

    EasyLoading.dismiss();

    if (result.isError) {
      EasyLoading.showError(result.error);
    } else {
      EasyLoading.showSuccess(result.value);
      // Clear form and navigate back
      amount.clear();
      message.clear();
      referenceNumber.clear();
      setState(() {
        _screenshotImage = null;
      });
      // Optionally navigate back
      if (mounted) {
        Navigator.of(context).pop();
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
      EasyLoading.showError('Failed to pick image: $e');
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
      EasyLoading.showError('Failed to take photo: $e');
    }
  }

  Future<void> _processImageWithTextExtraction(XFile image) async {
    setState(() {
      _screenshotImage = image;
    });

    // Show loading while extracting text
    EasyLoading.show(status: 'Analyzing image...');

    try {
      final paymentData = await PaymentTextExtractor.extractPaymentData(image);

      EasyLoading.dismiss();

      if (paymentData.success) {
        // Auto-fill fields if data was extracted successfully
        if (paymentData.referenceNumber.isNotEmpty) {
          setState(() {
            referenceNumber.text = paymentData.referenceNumber;
          });
        }
        if (paymentData.amount.isNotEmpty && amount.text.isEmpty) {
          setState(() {
            amount.text = paymentData.amount;
          });
        }

        // Show success message
        EasyLoading.showSuccess('Payment details extracted!');

        // Show extracted data dialog for user confirmation
        _showExtractedDataDialog(paymentData);
      } else {
        EasyLoading.showInfo(
          'Could not extract payment details automatically. Please fill manually.',
        );
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Failed to analyze image: $e');
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

  Future<void> openGCashApp() async {
    AppInfo? app = await InstalledApps.getAppInfo(
      'com.globe.gcash.android',
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
          title: Text(
            'Payment',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: PawsColors.textPrimary,
            ),
          ),
        ),
        body: RefreshIndicator(
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
                  // GCash Payment Information Card
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
                              'GCash Payment',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            PawsText(
                              'Send your donation to the details below',
                              fontSize: 13,
                              color: PawsColors.textSecondary,
                            ),
                          ],
                        ),
                        SizedBox(height: 16),

                        // GCash Number Section
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
                                      EasyLoading.showSuccess(
                                        'Copied to clipboard!',
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

                        // QR Code Section
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
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: PawsColors.border,
                                    ),
                                  ),
                                  child: NetworkImageView(
                                    fundraising!.qrCode!,
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
                  ),
                  SizedBox(height: 16),

                  // Payment Steps Guide
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
                                'Open your GCash app',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              content: [
                                Text(
                                  'Launch the GCash app on your mobile device.',
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
                                if (fundraising?.qrCode != null)
                                  Text(
                                    'Scan the QR code above or manually enter the GCash number.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: PawsColors.textSecondary,
                                    ),
                                  )
                                else
                                  Text(
                                    'Use "Send Money" and enter the GCash number above.',
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

                  Row(
                    spacing: 5,
                    children: [
                      CircleAvatar(
                        radius: 15,
                        foregroundImage: AssetImage('assets/images/gcash.jpeg'),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PawsText('Pay with GCash'),
                          PawsText(
                            'Manual Payment',
                            fontSize: 16,
                            color: PawsColors.textSecondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16),

                  // Amount Field
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
                      final intValue = int.tryParse(value);
                      if (intValue == null) {
                        return 'Please enter a valid number';
                      }
                      final remaining =
                          (fundraising?.targetAmount ?? 0) -
                          (fundraising?.raisedAmount ?? 0);

                      if (intValue > remaining) {
                        return 'Amount exceeds remaining target amount of ${remaining.displayMoney()}';
                      }
                      if (intValue < 50) {
                        return 'Minimum amount is ₱50.00';
                      }

                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  // Reference Number Field
                  PawsTextField(
                    hint: 'Reference Number',
                    label: 'GCash Reference Number',
                    controller: referenceNumber,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the GCash reference number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextArea(
                    placeholder: PawsText('Message (optional)'),
                    controller: message,
                  ),
                  SizedBox(height: 16),

                  // Screenshot Upload Section
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
                        'Upload a clear screenshot of your GCash payment confirmation',
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
                ? 'Open GCash App'
                : 'Submit Donation',
            onPressed: () {
              if (referenceNumber.text.isEmpty) {
                openGCashApp();
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
