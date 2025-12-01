import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/extension/ext.dart';
import 'package:paws_connect/core/theme/paws_theme.dart';
import 'package:paws_connect/core/widgets/button.dart';
import 'package:paws_connect/core/widgets/text.dart';
import 'package:paws_connect/dependency.dart';
import 'package:paws_connect/features/profile/provider/profile_provider.dart';
import 'package:paws_connect/features/profile/repository/profile_repository.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/services/loading_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/supabase/client.dart';

@RoutePage()
class UserHouseScreen extends StatefulWidget implements AutoRouteWrapper {
  const UserHouseScreen({super.key});

  @override
  State<UserHouseScreen> createState() => _UserHouseScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<ProfileRepository>(),
      child: this,
    );
  }
}

class _UserHouseScreenState extends State<UserHouseScreen> {
  RealtimeChannel? userChannel;
  final ImagePicker _picker = ImagePicker();
  List<XFile> selectedImages = [];

  void listenToUserUpdates() {
    debugPrint(
      'UserHouseScreen: Setting up user updates listener for user ID: $USER_ID',
    );
    userChannel = supabase.channel('public:users:id=eq.$USER_ID');
    userChannel
        ?.onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'users',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: USER_ID,
          ),
          callback: (payload) {
            debugPrint(
              'UserHouseScreen: User update received: ${payload.newRecord}',
            );
            debugPrint('User update received: ${payload.newRecord}');
            if (!mounted) return;
            context.read<ProfileRepository>().fetchUserProfile(USER_ID ?? '');
          },
        )
        .subscribe();
    debugPrint(
      'UserHouseScreen: User updates listener subscribed successfully',
    );
  }

  void uploadImages(List<XFile> images) async {
    debugPrint(
      'UserHouseScreen: Starting image upload for ${images.length} images',
    );
    try {
      final result = await LoadingService.showWhileExecuting(
        context,
        ProfileProvider().uploadHouseImages(USER_ID ?? "", images),
        message: 'Uploading images...',
      );

      if (result.isError) {
        debugPrint('UserHouseScreen: Failed to upload images: ${result.error}');
        EasyLoading.showError('Failed to upload images');
      } else {
        debugPrint('UserHouseScreen: Images uploaded successfully');
        EasyLoading.showSuccess('Images uploaded successfully');
        setState(() {
          selectedImages.clear();
        });
      }
    } catch (e) {
      debugPrint('UserHouseScreen: Exception during image upload: $e');
      EasyLoading.showError('Failed to upload images');
    }
  }

  @override
  void initState() {
    super.initState();
    debugPrint('UserHouseScreen: UserHouseScreen initialized');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      debugPrint(
        'UserHouseScreen: Fetching user profile for user ID: $USER_ID',
      );
      context.read<ProfileRepository>().fetchUserProfile(USER_ID ?? '');
      listenToUserUpdates();
    });
  }

  @override
  void dispose() {
    debugPrint('UserHouseScreen: Disposing UserHouseScreen');
    userChannel?.unsubscribe();
    super.dispose();
  }

  void _showImagePickerBottomSheet() {
    debugPrint('UserHouseScreen: Opening image picker bottom sheet');
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const PawsText(
                        'Add House Images',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: PawsElevatedButton(
                          label: 'Camera',
                          icon: Icons.camera_alt,
                          onPressed: () async {
                            debugPrint(
                              'UserHouseScreen: Camera button pressed',
                            );
                            final XFile? image = await _picker.pickImage(
                              source: ImageSource.camera,
                              imageQuality: 80,
                            );
                            if (image != null) {
                              debugPrint(
                                'UserHouseScreen: Image captured from camera: ${image.path}',
                              );
                              setModalState(() {
                                selectedImages.add(image);
                              });
                              setState(() {});
                            } else {
                              debugPrint(
                                'UserHouseScreen: Camera capture cancelled',
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: PawsElevatedButton(
                          label: 'Gallery',
                          icon: Icons.photo_library,
                          onPressed: () async {
                            debugPrint(
                              'UserHouseScreen: Gallery button pressed',
                            );
                            final List<XFile> images = await _picker
                                .pickMultiImage(imageQuality: 80);
                            if (images.isNotEmpty) {
                              debugPrint(
                                'UserHouseScreen: Selected ${images.length} images from gallery',
                              );
                              setModalState(() {
                                selectedImages.addAll(images);
                              });
                              setState(() {});
                            } else {
                              debugPrint(
                                'UserHouseScreen: Gallery selection cancelled',
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  if (selectedImages.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const PawsText(
                      'Selected Images:',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedImages.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(selectedImages[index].path),
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.image),
                                      );
                                    },
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      debugPrint(
                                        'UserHouseScreen: Removing image at index $index',
                                      );
                                      setModalState(() {
                                        selectedImages.removeAt(index);
                                      });
                                      setState(() {});
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: PawsElevatedButton(
                        label: 'Upload Images (${selectedImages.length})',
                        icon: Icons.cloud_upload,
                        onPressed: selectedImages.isEmpty
                            ? null
                            : () {
                                debugPrint(
                                  'UserHouseScreen: Uploading ${selectedImages.length} selected images',
                                );
                                Navigator.pop(context);
                                uploadImages(selectedImages);
                              },
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select((ProfileRepository bloc) => bloc.userProfile);
    debugPrint(
      'UserHouseScreen: Building UserHouseScreen, user profile: ${user != null ? "loaded" : "null"}',
    );
    if (user?.houseImages != null) {
      debugPrint(
        'UserHouseScreen: User has ${user!.houseImages!.length} house images',
      );
    }
    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'House Details',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          centerTitle: true,
        ),
        body: SizedBox(
          height: MediaQuery.sizeOf(context).height,
          width: MediaQuery.sizeOf(context).width,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PawsText(
                      'House images',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: PawsColors.textPrimary,
                    ),
                    PawsTextButton(
                      label: 'Update Images',
                      icon: LucideIcons.plus,
                      onPressed: _showImagePickerBottomSheet,
                    ),
                  ],
                ),
                if (user != null &&
                    user.houseImages != null &&
                    user.houseImages!.isNotEmpty) ...{
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.0,
                        ),
                    itemCount: user.houseImages!.length,
                    itemBuilder: (context, index) {
                      final imageUrl = user.houseImages![index];
                      return GestureDetector(
                        onTap: () {
                          debugPrint(
                            'UserHouseScreen: Opening full screen view for image: $imageUrl',
                          );
                          // Show full screen image
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              backgroundColor: Colors.transparent,
                              child: Stack(
                                children: [
                                  Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        imageUrl.transformedUrl,
                                        fit: BoxFit.contain,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                              if (loadingProgress == null) {
                                                return child;
                                              }
                                              return Container(
                                                width: 200,
                                                height: 200,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              );
                                            },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                width: 200,
                                                height: 200,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: const Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.error_outline,
                                                      size: 32,
                                                    ),
                                                    SizedBox(height: 8),
                                                    Text(
                                                      'Failed to load image',
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 40,
                                    right: 20,
                                    child: IconButton(
                                      onPressed: () => Navigator.pop(context),
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.black54,
                                        shape: const CircleBorder(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imageUrl.transformedUrl,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: Colors.grey,
                                        size: 24,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Failed to load',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 10,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                } else ...{
                  SizedBox(height: 8),
                  PawsText('No house images added.'),
                  SizedBox(height: 8),
                  PawsElevatedButton(
                    label: 'Add Images',
                    isFullWidth: false,
                    icon: LucideIcons.housePlus,
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                    onPressed: _showImagePickerBottomSheet,
                  ),
                },
              ],
            ),
          ),
        ),
      ),
    );
  }
}
