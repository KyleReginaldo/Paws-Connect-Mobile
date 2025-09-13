import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/core/widgets/text_field.dart';
import 'package:paws_connect/features/forum/provider/forum_provider.dart';

import '../../../core/theme/paws_theme.dart';
import '../../../core/widgets/text.dart';

@RoutePage()
class AddForumScreen extends StatefulWidget {
  const AddForumScreen({super.key});

  @override
  State<AddForumScreen> createState() => _AddForumScreenState();
}

class _AddForumScreenState extends State<AddForumScreen> {
  final forumName = TextEditingController();
  bool _isLoading = false;

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
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Forum created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.router.maybePop(true); // Navigate back
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const PawsText(
          'Create Forum',
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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
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

              // Form Section
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

              const Spacer(),

              // Create Button
              SizedBox(
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
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const PawsText(
                          'Create Forum',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
