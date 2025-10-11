// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/extension/int.ext.dart';
import 'package:paws_connect/core/widgets/text.dart';
import 'package:paws_connect/core/widgets/text_field.dart';
import 'package:paws_connect/features/donation/provider/direct_donation_provider.dart';
import 'package:paws_connect/features/payment/services/payment_text_extractor.dart';
import 'package:paws_connect/features/profile/repository/profile_repository.dart';
import 'package:provider/provider.dart';

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProfileRepository>().fetchUserProfile(USER_ID ?? "");
      context.read<FundraisingRepository>().fetchFundraisingById(
        widget.fundraisingId,
      );
    });
  }

  final amount = TextEditingController();
  final message = TextEditingController();
  final referenceNumber = TextEditingController();
  final formKey = GlobalKey<FormState>();
  XFile? _screenshotImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
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
          referenceNumber.text = paymentData.referenceNumber;
        }
        if (paymentData.amount.isNotEmpty && amount.text.isEmpty) {
          amount.text = paymentData.amount;
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

  @override
  Widget build(BuildContext context) {
    final fundraising = context.watch<FundraisingRepository>().fundraising;
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ProfileRepository>().fetchUserProfile(USER_ID ?? "");
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
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

                // Message Field
                PawsTextField(
                  hint: 'Message (optional)',
                  label: 'Message to fundraiser',
                  controller: message,
                  maxLines: 3,
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
                SizedBox(height: 24),

                PawsElevatedButton(
                  label: 'Submit Donation',
                  onPressed: handleDonation,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
