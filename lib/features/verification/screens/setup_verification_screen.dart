import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/core/theme/paws_theme.dart';
import 'package:paws_connect/core/widgets/button.dart';
import 'package:paws_connect/core/widgets/text.dart';
import 'package:paws_connect/core/widgets/text_field.dart';
import 'package:paws_connect/features/profile/provider/profile_provider.dart';

/// ID Verification screen with manual photo capture and form input
@RoutePage()
class SetUpVerificationScreen extends StatefulWidget {
  const SetUpVerificationScreen({super.key});

  @override
  State<SetUpVerificationScreen> createState() =>
      _SetUpVerificationScreenState();
}

class _SetUpVerificationScreenState extends State<SetUpVerificationScreen> {
  // Photo capture state
  XFile? _frontIdPhoto;
  bool _submitting = false;
  String? _error;
  bool _hasAttemptedSubmit = false; // Track if user has attempted to submit
  final ImagePicker _picker = ImagePicker();

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _idNumberController = TextEditingController();
  final _idNameController = TextEditingController();
  final _idExpirationController = TextEditingController();
  String _selectedIdType = 'PHILSYS_ID';

  // Available ID types
  static const List<String> _idTypes = [
    'PHILSYS_ID',
    'PASSPORT',
    'DRIVER_LICENSE',
    'SSS_ID',
    'UMID_CARD',
    'GSIS_ID',
    'PRC_ID',
    'TIN_ID',
    'POSTAL_ID',
    'VOTER_ID',
    'PHILHEALTH_ID',
    'PAGIBIG_ID',
    'SENIOR_CITIZEN_ID',
    'PWD_ID',
    'STUDENT_ID',
    'OFW_ID',
    'NBI_CLEARANCE',
    'POLICE_CLEARANCE',
    'BARANGAY_ID',
    'FIREARMS_LICENSE_ID',
    'IBP_ID',
    'SEAMAN_BOOK',
    'ACR_I_CARD',
  ];

  @override
  void dispose() {
    _idNumberController.dispose();
    _idNameController.dispose();
    _idExpirationController.dispose();
    super.dispose();
  }

  String _formatIdTypeName(String idType) {
    return idType
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Future<void> _capturePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (photo != null) {
        setState(() {
          _frontIdPhoto = photo;
          _error = null;
          _hasAttemptedSubmit = false; // Reset validation state
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to capture photo: $e';
      });
    }
  }

  void _removePhoto() {
    setState(() {
      _frontIdPhoto = null;
      _hasAttemptedSubmit = false; // Reset validation state
    });
  }

  Future<void> _submitVerification() async {
    // Set attempted submit flag for validation UI
    setState(() {
      _hasAttemptedSubmit = true;
    });

    // Validate form fields first
    if (!_formKey.currentState!.validate()) return;

    // Validate photo
    if (_frontIdPhoto == null) {
      EasyLoading.showError('Please capture a photo of your ID');
      return;
    }

    // Validate user authentication
    if (USER_ID == null || USER_ID!.isEmpty) {
      EasyLoading.showError('User not authenticated');
      return;
    }

    setState(() => _submitting = true);
    EasyLoading.show(status: 'Submitting verification...');

    try {
      // Parse the expiration date
      DateTime expirationDate = DateTime.now().add(
        Duration(days: 365 * 5),
      ); // Default 5 years
      try {
        expirationDate = DateTime.parse(_idExpirationController.text);
      } catch (e) {
        // If parsing fails, use default or try alternative formats
        debugPrint('Date parsing failed, using default expiration: $e');
      }

      // For now, using placeholder URL - in production you would upload the photos first

      final result = await ProfileProvider().submitIdVerification(
        userId: USER_ID!,
        idNumber: _idNumberController.text.trim(),
        idAttachment: _frontIdPhoto!,
        idName: _idNameController.text.trim(),
        idExpiration: expirationDate,
        idType: _selectedIdType,
      );

      EasyLoading.dismiss();

      if (result.isSuccess) {
        EasyLoading.showSuccess(result.value);
        // Navigate back or to profile
        context.router.maybePop();
      } else {
        EasyLoading.showError(result.error);
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showError('Failed to submit verification: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _buildPhotoCapture(
    String title,
    XFile? photo, {
    bool showError = false,
  }) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: showError
              ? Colors.red.shade400
              : (photo != null ? Colors.green.shade400 : Colors.grey.shade300),
          width: showError || photo != null ? 2 : 1,
        ),
      ),
      child: photo == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.camera,
                  size: 48,
                  color: showError ? Colors.red.shade400 : Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                PawsText(
                  'Tap to capture $title',
                  fontSize: 14,
                  color: showError ? Colors.red.shade600 : Colors.grey.shade600,
                ),
                if (showError) ...[
                  const SizedBox(height: 8),
                  PawsText(
                    'Photo is required',
                    fontSize: 12,
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ],
            )
          : Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(photo.path),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // Success indicator
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                // Remove button
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      onPressed: () => _removePhoto(),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildContent() {
    if (_error != null) {
      return _MessageBox(
        color: Colors.red.withValues(alpha: 0.08),
        border: Colors.redAccent.withValues(alpha: 0.4),
        child: PawsText('Error: $_error', color: Colors.red, fontSize: 13),
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo capture section
          const PawsText(
            'ID Photo',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: PawsColors.textPrimary,
          ),
          const SizedBox(height: 12),

          // Front ID Photo
          const PawsText(
            'Photo of ID',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: PawsColors.textPrimary,
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _capturePhoto(),
            child: _buildPhotoCapture(
              'your ID',
              _frontIdPhoto,
              showError: _hasAttemptedSubmit && _frontIdPhoto == null,
            ),
          ),
          const SizedBox(height: 24),

          // Form section
          const PawsText(
            'ID Details',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: PawsColors.textPrimary,
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PawsText(
                'ID Type',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: PawsColors.textPrimary,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedIdType,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                items: _idTypes.map((String idType) {
                  return DropdownMenuItem<String>(
                    value: idType,
                    child: PawsText(_formatIdTypeName(idType), fontSize: 14),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedIdType = newValue;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an ID type';
                  }
                  return null;
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          PawsTextField(
            label: 'ID Number',
            controller: _idNumberController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter ID number';
              }
              if (value.trim().length < 3) {
                return 'ID number must be at least 3 characters';
              }
              // Remove special characters and spaces for validation
              final cleanValue = value.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
              if (cleanValue.length < 3) {
                return 'ID number must contain at least 3 alphanumeric characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          PawsTextField(
            label: 'Full Name',
            controller: _idNameController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter full name';
              }
              if (value.trim().length < 2) {
                return 'Full name must be at least 2 characters';
              }
              // Check if name contains at least one letter
              if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
                return 'Full name must contain at least one letter';
              }
              // Check for reasonable name format (letters, spaces, periods, hyphens, apostrophes)
              if (!RegExp(r"^[a-zA-Z\s\.\-']+$").hasMatch(value.trim())) {
                return 'Full name contains invalid characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          PawsTextField(
            label: 'Expiration Date (YYYY-MM-DD)',
            controller: _idExpirationController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter expiration date';
              }

              // Check date format
              if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value.trim())) {
                return 'Please use YYYY-MM-DD format (e.g., 2025-12-31)';
              }

              // Try parsing the date
              try {
                final date = DateTime.parse(value.trim());
                final now = DateTime.now();

                // Check if date is in the past
                if (date.isBefore(now)) {
                  return 'Expiration date cannot be in the past';
                }

                // Check if date is too far in the future (more than 50 years)
                final maxDate = now.add(Duration(days: 365 * 50));
                if (date.isAfter(maxDate)) {
                  return 'Expiration date seems too far in the future';
                }
              } catch (e) {
                return 'Please enter a valid date in YYYY-MM-DD format';
              }

              return null;
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: PawsElevatedButton(
              label: _submitting ? 'Submitting...' : 'Submit Verification',
              onPressed: _submitting ? null : _submitVerification,
              icon: LucideIcons.send,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: PawsColors.background,
        appBar: AppBar(
          title: const PawsText(
            'ID Verification',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: PawsColors.primary,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.router.maybePop(),
          ),
          actions: [
            if (_frontIdPhoto != null)
              IconButton(
                tooltip: 'Clear Photo',
                onPressed: () => setState(() {
                  _frontIdPhoto = null;
                  _idNumberController.clear();
                  _idNameController.clear();
                  _selectedIdType = 'PHILSYS_ID';
                  _idExpirationController.clear();
                  _error = null;
                  _hasAttemptedSubmit = false; // Reset validation state
                }),
                icon: const Icon(Icons.refresh),
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: PawsColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: PawsColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.shield,
                      color: PawsColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: const PawsText(
                        'Take a photo of your government-issued ID and fill in the details to verify your identity.',
                        fontSize: 13,
                        color: PawsColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildContent(),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageBox extends StatelessWidget {
  final Widget child;
  final Color? color;
  final Color? border;
  const _MessageBox({required this.child, this.color, this.border});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? Colors.grey.shade100,
        border: Border.all(color: border ?? Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}
