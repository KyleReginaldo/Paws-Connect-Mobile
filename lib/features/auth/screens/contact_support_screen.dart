import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/services/email_service.dart';
import 'package:paws_connect/core/services/loading_service.dart';
import 'package:paws_connect/core/theme/paws_theme.dart';
import 'package:paws_connect/core/widgets/button.dart';
import 'package:paws_connect/core/widgets/text.dart';
import 'package:paws_connect/dependency.dart';
import 'package:paws_connect/features/profile/repository/profile_repository.dart';
import 'package:provider/provider.dart';

@RoutePage()
class ContactSupportScreen extends StatefulWidget implements AutoRouteWrapper {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<ProfileRepository>(),
      child: this,
    );
  }
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  String _selectedCategory = 'General Inquiry';
  final List<String> _categories = [
    'General Inquiry',
    'Account Issues',
    'Technical Problems',
    'Pet Adoption',
    'Payment Issues',
    'App Feedback',
    'Report a Bug',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final user = context.read<ProfileRepository>().userProfile;
    if (user != null) {
      _nameController.text = user.username;
      // You might want to add email field to user profile, for now we'll leave it empty
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendSupportEmail() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final result = await LoadingService.showWhileExecuting(
        context,
        _submitSupportRequest(),
        message: 'Sending your message...',
      );

      if (!mounted) return;

      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your support request has been sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Clear form
        _subjectController.clear();
        _messageController.clear();
        setState(() {
          _selectedCategory = 'General Inquiry';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send your message. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('ContactSupport: Error sending email: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _submitSupportRequest() async {
    final subject = '[$_selectedCategory] ${_subjectController.text}';

    // Send support email
    final supportEmailSent = await EmailService.sendSupportEmail(
      userEmail: _emailController.text,
      userName: _nameController.text,
      subject: subject,
      message: _messageController.text,
    );

    // Send confirmation email to user
    if (supportEmailSent && _emailController.text.isNotEmpty) {
      await EmailService.sendConfirmationEmail(
        userEmail: _emailController.text,
        userName: _nameController.text,
        subject: subject,
      );
    }

    return supportEmailSent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Contact Support',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header info
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
                      LucideIcons.headphones,
                      color: PawsColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PawsText(
                            'Need Help?',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: PawsColors.primary,
                          ),
                          const SizedBox(height: 4),
                          PawsText(
                            'Our support team is here to help you. Send us a message and we\'ll get back to you soon.',
                            fontSize: 14,
                            color: PawsColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Name field
              PawsText(
                'Your Name *',
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter your full name',
                  prefixIcon: const Icon(LucideIcons.user),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: PawsColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: PawsColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: PawsColors.primary),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Email field
              PawsText(
                'Your Email *',
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Enter your email address',
                  prefixIcon: const Icon(LucideIcons.mail),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: PawsColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: PawsColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: PawsColors.primary),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email address';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Category dropdown
              PawsText('Category *', fontSize: 14, fontWeight: FontWeight.w500),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  prefixIcon: const Icon(LucideIcons.tag),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: PawsColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: PawsColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: PawsColors.primary),
                  ),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Subject field
              PawsText('Subject *', fontSize: 14, fontWeight: FontWeight.w500),
              const SizedBox(height: 8),
              TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(
                  hintText: 'Brief description of your issue',
                  prefixIcon: const Icon(LucideIcons.fileText),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: PawsColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: PawsColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: PawsColors.primary),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a subject';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Message field
              PawsText('Message *', fontSize: 14, fontWeight: FontWeight.w500),
              const SizedBox(height: 8),
              TextFormField(
                controller: _messageController,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText:
                      'Please describe your issue or question in detail...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: PawsColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: PawsColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: PawsColors.primary),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your message';
                  }
                  if (value.trim().length < 10) {
                    return 'Please provide more details (at least 10 characters)';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Send button
              SizedBox(
                width: double.infinity,
                child: PawsElevatedButton(
                  label: 'Send Message',
                  icon: LucideIcons.send,
                  onPressed: _sendSupportEmail,
                  borderRadius: 8,
                ),
              ),

              const SizedBox(height: 16),

              // Additional info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.info,
                      size: 16,
                      color: PawsColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: PawsText(
                        'We typically respond within 24-48 hours. You\'ll receive a confirmation email once we receive your message.',
                        fontSize: 12,
                        color: PawsColors.textSecondary,
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
}
