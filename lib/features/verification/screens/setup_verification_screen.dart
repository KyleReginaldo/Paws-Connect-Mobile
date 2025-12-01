import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/enum/id_type.enum.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/core/theme/paws_theme.dart';
import 'package:paws_connect/core/widgets/button.dart';
import 'package:paws_connect/core/widgets/text.dart';
import 'package:paws_connect/core/widgets/text_field.dart';
import 'package:paws_connect/features/profile/provider/profile_provider.dart';
import 'package:paws_connect/features/verification/services/id_text_extractor.dart';

import '../../../core/services/loading_service.dart';

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

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _middleInitialController = TextEditingController();

  final _addressController = TextEditingController();
  final _dateOfBirthController = TextEditingController();
  DateTime? _selectedDateOfBirth;

  // ID Type selection
  String? _selectedIdType;
  final List<String> _idTypes = IdType.allLabels;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleInitialController.dispose();
    _addressController.dispose();
    _dateOfBirthController.dispose();
    super.dispose();
  }

  Future<void> _showImageSourceDialog() async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: const Text('Add ID Photo'),
          content: const Text('Choose how you want to add your ID photo:'),
          actions: [
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
              icon: const Icon(LucideIcons.image),
              label: const Text('Gallery'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () => Navigator.of(context).pop(ImageSource.camera),
              icon: const Icon(LucideIcons.camera),
              label: const Text('Camera'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (source != null) {
      if (source == ImageSource.camera) {
        await _pickFromCamera();
      } else {
        await _pickFromGallery();
      }
    }
  }

  // Deprecated guided camera (landscape-only). Using system camera via ImagePicker instead.

  Future<void> _pickFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (pickedFile != null) {
        if (!mounted) return;

        setState(() {
          _frontIdPhoto = pickedFile;
          _error = null;
          _hasAttemptedSubmit = false; // Reset validation state
        });

        // Extract text from the selected ID if ID type is selected
        if (_selectedIdType != null) {
          await _extractTextFromId();
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to pick image: $e';
      });
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (pickedFile != null) {
        if (!mounted) return;

        setState(() {
          _frontIdPhoto = pickedFile;
          _error = null;
          _hasAttemptedSubmit = false; // Reset validation state
        });

        // Extract text from the captured ID if ID type is selected
        if (_selectedIdType != null) {
          await _extractTextFromId();
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to capture image: $e';
      });
    }
  }

  Future<void> _extractTextFromId() async {
    if (_frontIdPhoto == null || _selectedIdType == null) return;

    try {
      // Show loading indicator
      LoadingService.unawaited(
        LoadingService.show(context, message: 'Extracting information...'),
      );

      final extractionResult = await IdTextExtractor.extractIdData(
        imageFile: _frontIdPhoto!,
        idType: _selectedIdType!,
      );

      if (mounted) {
        LoadingService.dismiss(context);
      }

      if (!mounted) return;

      if (extractionResult.isSuccessful) {
        // Auto-populate form fields with extracted data
        setState(() {
          if (extractionResult.firstName != null &&
              _firstNameController.text.isEmpty) {
            _firstNameController.text = _toTitleCase(
              extractionResult.firstName!,
            );
          }
          if (extractionResult.lastName != null &&
              _lastNameController.text.isEmpty) {
            _lastNameController.text = _toTitleCase(extractionResult.lastName!);
          }
          if (extractionResult.middleName != null &&
              _middleInitialController.text.isEmpty) {
            // Take first character for middle initial
            _middleInitialController.text =
                extractionResult.middleName!.isNotEmpty
                ? extractionResult.middleName!.substring(0, 1).toUpperCase()
                : '';
          }
          if (extractionResult.address != null &&
              _addressController.text.isEmpty) {
            _addressController.text = _toTitleCase(extractionResult.address!);
          }
        });

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ID information extracted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Show error but don't block user from continuing
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Could not extract text from ID: ${extractionResult.error ?? "Unknown error"}',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        LoadingService.dismiss(context);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing ID: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _toTitleCase(String text) {
    return text
        .toLowerCase()
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }

  void _removePhoto() {
    setState(() {
      _frontIdPhoto = null;
      _hasAttemptedSubmit = false; // Reset validation state
    });
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime now = DateTime.now();
    final DateTime eighteenYearsAgo = DateTime(
      now.year - 18,
      now.month,
      now.day,
    );
    final DateTime hundredYearsAgo = DateTime(
      now.year - 100,
      now.month,
      now.day,
    );

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? eighteenYearsAgo,
      firstDate: hundredYearsAgo,
      lastDate: eighteenYearsAgo,
      helpText: 'Select your date of birth',
      cancelText: 'Cancel',
      confirmText: 'OK',
    );

    if (pickedDate != null && pickedDate != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = pickedDate;
        _dateOfBirthController.text =
            '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
      });
    }
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please capture a photo of your ID'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Validate ID type
    if (_selectedIdType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your ID type'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Validate user authentication
    if (USER_ID == null || USER_ID!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not authenticated'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Validate date of birth
    if (_selectedDateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your date of birth'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final result = await LoadingService.showWhileExecuting(
        context,
        ProfileProvider().submitIdVerification(
          userId: USER_ID!,
          idNumber:
              '', // No longer using ID number - keeping empty for API compatibility
          idAttachment: _frontIdPhoto!,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          middleInitial: _middleInitialController.text.isNotEmpty
              ? _middleInitialController.text.trim()
              : null,
          address: _addressController.text.trim(),
          dateOfBirth: _selectedDateOfBirth!,
          idType: IdType.fromLabel(_selectedIdType!)?.name ?? _selectedIdType!,
        ),
        message: 'Submitting verification...',
      );

      if (result.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(result.value)));
          context.router.maybePop(true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(result.error)));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit verification: $e')),
        );
      }
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.camera,
                      size: 24,
                      color: showError
                          ? Colors.red.shade400
                          : Colors.grey.shade400,
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      LucideIcons.image,
                      size: 24,
                      color: showError
                          ? Colors.red.shade400
                          : Colors.grey.shade400,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                PawsText(
                  'Tap to add photo of $title',
                  fontSize: 14,
                  color: showError ? Colors.red.shade600 : Colors.grey.shade600,
                ),
                if (showError) ...[
                  const SizedBox(height: 4),
                  PawsText(
                    'Photo is required',
                    fontSize: 12,
                    color: Colors.red.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ] else ...[
                  const SizedBox(height: 4),
                  PawsText(
                    'Camera capture or gallery selection',
                    fontSize: 12,
                    color: Colors.grey.shade500,
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
          // ID Type selection
          const PawsText(
            'ID Type',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: PawsColors.textPrimary,
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                color: _hasAttemptedSubmit && _selectedIdType == null
                    ? Colors.red
                    : Colors.grey.shade300,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedIdType,
                hint: const Text(
                  'Select ID type',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                isExpanded: true,
                items: _idTypes.map((String idType) {
                  return DropdownMenuItem<String>(
                    value: idType,
                    child: Text(
                      idType,
                      style: const TextStyle(
                        fontSize: 14,
                        color: PawsColors.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedIdType = newValue;
                  });
                },
              ),
            ),
          ),

          if (_hasAttemptedSubmit && _selectedIdType == null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Please select your ID type',
                style: TextStyle(color: Colors.red.shade700, fontSize: 12),
              ),
            ),

          SizedBox(height: 16),
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
            onTap: () => _showImageSourceDialog(),
            child: _buildPhotoCapture(
              'your ID',
              _frontIdPhoto,
              showError: _hasAttemptedSubmit && _frontIdPhoto == null,
            ),
          ),

          const SizedBox(height: 16),

          // Extract Information Button
          if (_frontIdPhoto != null && _selectedIdType != null) ...[
            SizedBox(
              width: double.infinity,
              child: PawsElevatedButton(
                label: 'Extract Information from ID',
                onPressed: _extractTextFromId,
                icon: LucideIcons.scanText,
                backgroundColor: Colors.grey[100],
                foregroundColor: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200, width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.info,
                    color: Colors.amber.shade700,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: PawsText(
                      'Note: Text extraction may not be 100% accurate. Please review and correct any information as needed.',
                      fontSize: 12,
                      color: Colors.amber.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Form section
          const PawsText(
            'Personal Details',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: PawsColors.textPrimary,
          ),
          const SizedBox(height: 12),
          PawsTextField(
            label: 'First Name',
            controller: _firstNameController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter first name';
              }
              if (value.trim().length < 2) {
                return 'First name must be at least 2 characters';
              }
              // Check if name contains at least one letter
              if (!RegExp(r'[a-zA-ZñÑ]').hasMatch(value)) {
                return 'First name must contain at least one letter';
              }
              // Check for reasonable name format (letters, spaces, periods, hyphens, apostrophes)
              if (!RegExp(r"^[a-zA-ZñÑ\s\.\-']+$").hasMatch(value.trim())) {
                return 'First name contains invalid characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          PawsTextField(
            label: 'Last Name',
            controller: _lastNameController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter last name';
              }
              if (value.trim().length < 2) {
                return 'Last name must be at least 2 characters';
              }
              // Check if name contains at least one letter
              if (!RegExp(r'[a-zA-ZñÑ]').hasMatch(value)) {
                return 'Last name must contain at least one letter';
              }
              // Check for reasonable name format (letters, spaces, periods, hyphens, apostrophes)
              if (!RegExp(r"^[a-zA-ZñÑ\s\.\-']+$").hasMatch(value.trim())) {
                return 'Last name contains invalid characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          PawsTextField(
            label: 'Middle Initial',
            controller: _middleInitialController,
            validator: (value) {
              if (value != null && value.trim().isNotEmpty) {
                // Check if it contains only valid letters (including ñ/Ñ)
                if (!RegExp(r'^[a-zA-Zñ\u00d1\s\.]+$').hasMatch(value.trim())) {
                  return 'Middle initial contains invalid characters';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          PawsTextField(
            label: 'Address',
            controller: _addressController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your address';
              }
              if (value.trim().length < 10) {
                return 'Please enter a complete address';
              }
              // Accept letters (including ñ/Ñ), numbers, spaces, commas, periods, hyphens
              if (!RegExp(
                r'^[a-zA-Zñ\u00d1\s\d,.\-]+$',
              ).hasMatch(value.trim())) {
                return 'Address contains invalid characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _selectDateOfBirth,
            child: AbsorbPointer(
              child: PawsTextField(
                label: 'Date of Birth',
                controller: _dateOfBirthController,
                suffixIcon: const Icon(Icons.calendar_today),
                validator: (value) {
                  if (_selectedDateOfBirth == null) {
                    return 'Please select your date of birth';
                  }
                  final now = DateTime.now();
                  final age = now.year - _selectedDateOfBirth!.year;
                  if (age < 18) {
                    return 'You must be at least 18 years old';
                  }
                  return null;
                },
              ),
            ),
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
          title: const Text(
            'ID Verification',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
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
                  _selectedIdType = null;
                  _firstNameController.clear();
                  _lastNameController.clear();
                  _middleInitialController.clear();
                  _addressController.clear();
                  _dateOfBirthController.clear();
                  _selectedDateOfBirth = null;
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
                        'Take a photo with our guided camera or select an existing image from your gallery. Supported IDs include government-issued, school, or other official identification documents.',
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
