import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/core/widgets/text_field.dart';
import 'package:paws_connect/dependency.dart';
import 'package:paws_connect/features/forum/provider/forum_provider.dart';
import 'package:paws_connect/features/profile/repository/image_repository.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/paws_theme.dart';
import '../../../core/widgets/text.dart';

@RoutePage()
class AddForumScreen extends StatefulWidget implements AutoRouteWrapper {
  const AddForumScreen({super.key});

  @override
  State<AddForumScreen> createState() => _AddForumScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<ImageRepository>(),
      child: this,
    );
  }
}

class _AddForumScreenState extends State<AddForumScreen> {
  final forumName = TextEditingController();
  bool _isLoading = false;
  bool private = false;
  XFile? forumImageFile;
  List<(String, bool, IconData)> forumTypes = [
    ('Public', false, LucideIcons.globe),
    ('Private', true, LucideIcons.globeLock),
  ];

  void handleAddForum({required String forumName}) async {
    if (forumName.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a forum name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ForumProvider().addForum(
        userId: USER_ID ?? "",
        forumName: forumName.trim(),
        private: private,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Forum created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.router.maybePop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create forum: $e'),
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
    forumName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageFile = context.select(
      (ImageRepository bloc) => bloc.selectedImage,
    );
    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text(
            'Create Forum',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: PawsColors.textPrimary,
            ),
            onPressed: () => context.router.pop(),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: PawsColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(width: 2, color: PawsColors.primary),
                      image: imageFile != null
                          ? DecorationImage(
                              image: FileImage(File(imageFile.path)),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Icon(
                      LucideIcons.pencil,
                      size: 18,
                      color: PawsColors.primary,
                    ),
                  ),
                ],
              ),
              Container(
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
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: PawsColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.forum_outlined,
                            color: PawsColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const PawsText(
                                'Start a New Discussion',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: PawsColors.textPrimary,
                              ),
                              const SizedBox(height: 4),
                              PawsText(
                                'Create a forum where pet lovers can connect, share experiences, and help each other',
                                fontSize: 14,
                                color: PawsColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Container(
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
                    const PawsText(
                      'Forum Details',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: PawsColors.textPrimary,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: forumTypes.map((type) {
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                private = type.$2;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: private == type.$2
                                    ? PawsColors.primary
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: private == type.$2
                                      ? PawsColors.primary
                                      : Colors.grey.withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  if (private == type.$2)
                                    BoxShadow(
                                      color: PawsColors.primary.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                ],
                              ),
                              child: Center(
                                child: Row(
                                  spacing: 5,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      type.$3,
                                      color: private == type.$2
                                          ? Colors.white
                                          : PawsColors.textSecondary,
                                      size: 16,
                                    ),
                                    PawsText(
                                      type.$1,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: private == type.$2
                                          ? Colors.white
                                          : PawsColors.textPrimary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    const PawsText(
                      'Forum Name',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: PawsColors.textPrimary,
                    ),
                    const SizedBox(height: 8),

                    PawsTextField(
                      hint: 'e.g., "Dog Training Tips" or "Cat Health Advice"',
                      controller: forumName,
                      maxLines: 1,
                    ),

                    const SizedBox(height: 12),

                    PawsText(
                      'Choose a clear, descriptive name that helps others understand what your forum is about.',
                      fontSize: 12,
                      color: PawsColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          margin: const EdgeInsets.all(16),
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading
                ? null
                : () {
                    handleAddForum(forumName: forumName.text);
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: PawsColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              disabledBackgroundColor: PawsColors.primary.withValues(
                alpha: 0.6,
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const PawsText(
                    'Create Forum',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
          ),
        ),
      ),
    );
  }
}
