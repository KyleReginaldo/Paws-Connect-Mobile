import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/features/profile/repository/image_repository.dart';
import 'package:paws_connect/features/profile/repository/profile_repository.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/paws_theme.dart';
import '../../../core/widgets/text.dart';
import '../../../core/widgets/text_field.dart';
import '../../../dependency.dart';
import '../models/user_profile_model.dart';
import '../provider/profile_provider.dart';

@RoutePage()
class EditProfileScreen extends StatefulWidget implements AutoRouteWrapper {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sl<ProfileRepository>()),
        ChangeNotifierProvider.value(value: ImageRepository()),
      ],
      child: this,
    );
  }
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _paymentMethodController = TextEditingController();

  bool _isLoading = false;
  bool _hasChanges = false;
  UserProfile? _originalProfile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final repo = context.read<ProfileRepository>();
      final imageRepo = context.read<ImageRepository>();

      // Listen to image repository changes
      imageRepo.addListener(_onFieldChanged);

      if (repo.userProfile != null) {
        _populateFields(repo.userProfile!);
      } else {
        repo.fetchUserProfile(USER_ID ?? "");
      }
    });
  }

  void _populateFields(UserProfile profile) {
    _originalProfile = profile;
    _usernameController.text = profile.username;
    _emailController.text = profile.email;
    _phoneController.text = profile.phoneNumber;
    _paymentMethodController.text = profile.paymentMethod ?? '';

    // Listen for changes
    _usernameController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _paymentMethodController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    final imageRepo = context.read<ImageRepository>();
    final hasChanges =
        _usernameController.text != _originalProfile?.username ||
        _emailController.text != _originalProfile?.email ||
        _phoneController.text != _originalProfile?.phoneNumber ||
        _paymentMethodController.text !=
            (_originalProfile?.paymentMethod ?? '') ||
        imageRepo.hasImageChanged;

    if (hasChanges != _hasChanges) {
      // Defer updating state to the end of this frame to avoid calling
      // setState during the widget build process (prevents '!_dirty' assert).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        // Re-check because value may have changed before the callback runs.
        final imageRepo2 = context.read<ImageRepository>();
        final newHasChanges =
            _usernameController.text != _originalProfile?.username ||
            _emailController.text != _originalProfile?.email ||
            _phoneController.text != _originalProfile?.phoneNumber ||
            _paymentMethodController.text !=
                (_originalProfile?.paymentMethod ?? '') ||
            imageRepo2.hasImageChanged;
        if (newHasChanges != _hasChanges) {
          setState(() {
            _hasChanges = newHasChanges;
          });
        }
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || !_hasChanges) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final imageRepo = context.read<ImageRepository>();

      final result = await ProfileProvider().updateUserProfile(
        userId: USER_ID ?? '',
        username: (_originalProfile?.username == _usernameController.text)
            ? null
            : _usernameController.text.trim(),
        image: imageRepo.selectedImage, // Pass the XFile directly
      );

      if (result.isError) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update profile: ${result.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                imageRepo.hasImageChanged
                    ? 'Profile and photo updated successfully!'
                    : 'Profile updated successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );

          // Clear the selected image after successful save
          imageRepo.clearImage();

          // Refresh the profile data
          final repo = context.read<ProfileRepository>();
          repo.fetchUserProfile(USER_ID ?? "");

          // Pop back to previous screen
          context.router.maybePop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Remove the listener we added to the image repository (if present)
    try {
      final imageRepo = context.read<ImageRepository>();
      imageRepo.removeListener(_onFieldChanged);
    } catch (_) {
      // If reading the provider fails during dispose, ignore.
    }

    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _paymentMethodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<ProfileRepository>();
    final imageRepo = context.watch<ImageRepository>();
    final user = repo.userProfile;

    // Populate fields when user data is loaded
    if (user != null && _originalProfile == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _populateFields(user);
      });
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const PawsText(
          'Edit Profile',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: PawsColors.textPrimary,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: PawsColors.textPrimary),
          onPressed: () => context.router.pop(),
        ),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          PawsColors.primary,
                        ),
                      ),
                    )
                  : const PawsText(
                      'Save',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: PawsColors.primary,
                    ),
            ),
        ],
      ),
      body: user == null
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(PawsColors.primary),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 8,
                            children: [
                              GestureDetector(
                                onTap: () =>
                                    imageRepo.showImageSourceDialog(context),
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: PawsColors.primary.withValues(
                                          alpha: 0.1,
                                        ),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: PawsColors.primary.withValues(
                                            alpha: 0.2,
                                          ),
                                          width: 3,
                                        ),
                                      ),
                                      child: imageRepo.isLoading
                                          ? const CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    PawsColors.primary,
                                                  ),
                                            )
                                          : imageRepo.selectedImage != null
                                          ? ClipOval(
                                              child: Image.file(
                                                File(
                                                  imageRepo.selectedImage!.path,
                                                ),
                                                fit: BoxFit.cover,
                                                width: 100,
                                                height: 100,
                                              ),
                                            )
                                          : user.profileImageLink == null
                                          ? const Icon(
                                              Icons.person,
                                              size: 50,
                                              color: PawsColors.primary,
                                            )
                                          : ClipOval(
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    user.profileImageLink!,
                                                fit: BoxFit.cover,
                                                width: 100,
                                                height: 100,
                                                placeholder: (context, url) =>
                                                    const CircularProgressIndicator(
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(PawsColors.primary),
                                                    ),
                                                errorWidget:
                                                    (
                                                      context,
                                                      url,
                                                      error,
                                                    ) => const Icon(
                                                      Icons.person,
                                                      size: 50,
                                                      color: PawsColors.primary,
                                                    ),
                                              ),
                                            ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: PawsColors.primary,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.camera_alt,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    PawsText(
                                      imageRepo.selectedImage != null
                                          ? 'Photo Selected'
                                          : 'Edit Photo',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: PawsColors.textPrimary,
                                    ),
                                    PawsText(
                                      imageRepo.selectedImage != null
                                          ? 'Tap to change photo'
                                          : 'Tap to add a clear photo',
                                      fontSize: 12,
                                      color: PawsColors.textSecondary,
                                    ),
                                    if (imageRepo.errorMessage != null) ...[
                                      const SizedBox(height: 4),
                                      PawsText(
                                        imageRepo.errorMessage!,
                                        fontSize: 11,
                                        color: Colors.red,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const PawsText(
                            'Username',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: PawsColors.textPrimary,
                          ),
                          const SizedBox(height: 6),
                          PawsTextField(
                            controller: _usernameController,
                            hint: 'Enter your username',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Username is required';
                              }
                              if (value.trim().length < 3) {
                                return 'Username must be at least 3 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Email
                          const PawsText(
                            'Email Address',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: PawsColors.textPrimary,
                          ),
                          const SizedBox(height: 6),
                          PawsTextField(
                            controller: _emailController,
                            hint: 'Enter your email',
                            keyboardType: TextInputType.emailAddress,
                            readOnly: true,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email is required';
                              }
                              if (!value.contains('@')) {
                                return 'Enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Phone Number
                          const PawsText(
                            'Phone Number',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: PawsColors.textPrimary,
                          ),
                          const SizedBox(height: 6),
                          PawsTextField(
                            controller: _phoneController,
                            hint: 'Enter your phone number',
                            readOnly: true,

                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Phone number is required';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Account Status Info
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getStatusColor(
                          user.status,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getStatusColor(
                            user.status,
                          ).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getStatusIcon(user.status),
                            color: _getStatusColor(user.status),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                PawsText(
                                  'Account Status: ${user.status.toUpperCase()}',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _getStatusColor(user.status),
                                ),
                                PawsText(
                                  _getStatusMessage(user.status),
                                  fontSize: 12,
                                  color: _getStatusColor(user.status),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'inactive':
        return Colors.red;
      default:
        return PawsColors.primary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Icons.check_circle_outline;
      case 'pending':
        return Icons.schedule;
      case 'inactive':
        return Icons.error_outline;
      default:
        return Icons.info_outline;
    }
  }

  String _getStatusMessage(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'Your account is fully active and verified';
      case 'pending':
        return 'Your account is pending verification';
      case 'inactive':
        return 'Your account is currently inactive';
      default:
        return 'Contact support for account status details';
    }
  }
}
