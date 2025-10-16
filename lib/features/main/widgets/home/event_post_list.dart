// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:paws_connect/features/events/models/event_model.dart';

import '../../../../core/router/app_route.gr.dart';
import '../../../../core/theme/paws_theme.dart';
import '../../../../core/widgets/text.dart';
import '../event_container.dart';

class EventPostList extends StatelessWidget {
  final OverlayPortalController overlayController;
  final List<Event> events;
  const EventPostList({
    super.key,
    required this.overlayController,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 5,
          mainAxisSize: MainAxisSize.min,
          children: [
            PawsText(
              'Posted by Admin',
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            GestureDetector(
              onTap: () {
                overlayController.toggle();
              },
              child: OverlayPortal(
                controller: overlayController,
                overlayChildBuilder: (context) {
                  return Positioned(
                    top: 85,
                    left: 50,
                    right: 50,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width * 0.70,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color.fromARGB(66, 94, 85, 85),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: PawsText(
                        'Events are posted by the admin to keep you informed about upcoming activities and important announcements.',
                      ),
                    ),
                  );
                },
                child: Icon(
                  Icons.info_outline,
                  size: 16,
                  color: PawsColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: ClampingScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: events.map((e) {
              return EventContainer(
                event: e,
                onTap: () => context.router.push(EventDetailRoute(id: e.id)),
                onSuggestionTap: (suggestion) {
                  showModalBottomSheet(
                    context: context,
                    shape: RoundedRectangleBorder(),
                    builder: (_) {
                      return SuggestionModal(
                        suggestion: suggestion,
                        eventContext: '${e.title}, ${e.description}',
                      );
                    },
                  );
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class SuggestionModal extends StatefulWidget {
  final String suggestion;
  final String eventContext;

  const SuggestionModal({
    super.key,
    required this.suggestion,
    required this.eventContext,
  });

  @override
  State<SuggestionModal> createState() => _SuggestionModalState();
}

class _SuggestionModalState extends State<SuggestionModal> {
  String? suggestionCompletion;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _generateSuggestion();
  }

  void _generateSuggestion() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await Gemini.instance
          .prompt(
            safetySettings: [
              SafetySetting(
                category: SafetyCategory.harassment,
                threshold: SafetyThreshold.blockLowAndAbove,
              ),
            ],
            parts: [
              Part.text(
                'Context: You are providing information for a pet adoption/animal welfare organization located at "Blk 4, 23 Officers Avenue, Bacoor, Cavite". '
                'This organization specializes in pet adoption services, animal shelter operations, fundraising campaigns, donation drives, community forums, community outreach programs, and various pet-related events.\n\n'
                'Based on the event: "${widget.eventContext}", provide detailed, helpful information about: "${widget.suggestion}". '
                'If the question relates to location or "where", mention that the organization is located at Blk 4, 23 Officers Avenue, Bacoor, Cavite. '
                'Consider aspects like adoption procedures, shelter services, volunteer opportunities, donation needs, event logistics, pet care requirements, and community involvement. '
                'Please provide a clear, informative response that would be helpful for someone interested in this pet welfare event or topic. '
                'IMPORTANT: Format your response using MARKDOWN syntax only. Use **text** for bold, *text* for italic, ## for headings, - for bullet points, and ` for code. '
                'DO NOT use HTML tags like <strong>, <b>, <em>, <i>, <p>, <br>, etc. Only use markdown formatting.',
              ),
            ],
          )
          .timeout(
            Duration(seconds: 30),
            onTimeout: () => throw TimeoutException(
              'Request timed out',
              Duration(seconds: 30),
            ),
          );

      if (mounted) {
        setState(() {
          suggestionCompletion = _cleanHtmlTags(
            response?.output ?? 'No response generated.',
          );
          isLoading = false;
        });
      }
    } on TimeoutException catch (e) {
      if (mounted) {
        setState(() {
          errorMessage =
              'Request timed out. Please check your internet connection and try again.';
          isLoading = false;
        });
      }
      debugPrint('Gemini timeout: $e');
    } catch (e) {
      if (mounted) {
        setState(() {
          // Handle specific Gemini API errors
          String userMessage = _getGeminiErrorMessage(e);
          errorMessage = userMessage;
          isLoading = false;
        });
      }
      debugPrint('Gemini API error: $e');
    }
  }

  String _cleanHtmlTags(String text) {
    // Remove common HTML tags and convert to markdown equivalent
    return text
        .replaceAll(RegExp(r'<strong>(.*?)</strong>'), '**\$1**')
        .replaceAll(RegExp(r'<b>(.*?)</b>'), '**\$1**')
        .replaceAll(RegExp(r'<em>(.*?)</em>'), '*\$1*')
        .replaceAll(RegExp(r'<i>(.*?)</i>'), '*\$1*')
        .replaceAll(RegExp(r'<p>(.*?)</p>'), '\$1\n\n')
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<h1>(.*?)</h1>'), '# \$1\n')
        .replaceAll(RegExp(r'<h2>(.*?)</h2>'), '## \$1\n')
        .replaceAll(RegExp(r'<h3>(.*?)</h3>'), '### \$1\n')
        .replaceAll(RegExp(r'<ul>(.*?)</ul>', dotAll: true), '\$1')
        .replaceAll(RegExp(r'<li>(.*?)</li>'), '- \$1\n')
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove any remaining HTML tags
        .replaceAll(RegExp(r'\n{3,}'), '\n\n') // Clean up excessive newlines
        .trim();
  }

  String _getGeminiErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('api key') ||
        errorString.contains('authentication')) {
      return 'Authentication error. Please contact support.';
    } else if (errorString.contains('quota') || errorString.contains('limit')) {
      return 'Service temporarily unavailable. Please try again later.';
    } else if (errorString.contains('safety') ||
        errorString.contains('blocked')) {
      return 'Content was blocked by safety filters. Please try a different request.';
    } else if (errorString.contains('network') ||
        errorString.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorString.contains('invalid') ||
        errorString.contains('malformed')) {
      return 'Invalid request. Please try again.';
    } else if (errorString.contains('server') ||
        errorString.contains('503') ||
        errorString.contains('502')) {
      return 'Server temporarily unavailable. Please try again in a moment.';
    } else {
      return 'AI service is currently unavailable. Please try again later.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.70,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(),
      width: MediaQuery.sizeOf(context).width,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PawsText(
              widget.suggestion,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: 10),
            if (isLoading)
              _buildSkeletonLoader()
            else if (errorMessage != null)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: PawsText(
                            'Error generating suggestion',
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    PawsText(
                      errorMessage!,
                      fontSize: 12,
                      color: Colors.red.shade600,
                    ),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: _generateSuggestion,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: PawsColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: PawsText(
                          'Try Again',
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              GptMarkdown(
                suggestionCompletion ?? 'No suggestions available.',
                style: TextStyle(fontSize: 14, color: PawsColors.textSecondary),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return AnimatedBuilder(
      animation: _getShimmerAnimation(),
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Generation Header
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '🤖 AI is analyzing "${widget.suggestion}"...',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Spacer(),
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Title skeleton
            _buildShimmerContainer(16, double.infinity),
            SizedBox(height: 12),

            // Paragraph skeletons with varying widths
            ...List.generate(
              5,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: _buildShimmerContainer(14, _getRandomWidth(index)),
              ),
            ),

            SizedBox(height: 16),

            // Bullet points skeleton
            ...List.generate(
              4,
              (index) => Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerContainer(6, 6, isCircle: true, topMargin: 4),
                    SizedBox(width: 8),
                    Expanded(
                      child: _buildShimmerContainer(14, _getBulletWidth(index)),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Footer skeleton
            _buildShimmerContainer(14, MediaQuery.sizeOf(context).width * 0.6),
          ],
        );
      },
    );
  }

  Widget _buildShimmerContainer(
    double height,
    double width, {
    bool isCircle = false,
    double topMargin = 0,
  }) {
    return Container(
      height: height,
      width: width,
      margin: EdgeInsets.only(top: topMargin),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade300,
            Colors.grey.shade200,
            Colors.grey.shade300,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: isCircle ? null : BorderRadius.circular(4),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }

  Animation<double> _getShimmerAnimation() {
    return AlwaysStoppedAnimation(0.0);
  }

  double _getRandomWidth(int index) {
    final widths = [
      double.infinity,
      MediaQuery.sizeOf(context).width * 0.9,
      MediaQuery.sizeOf(context).width * 0.75,
      double.infinity,
      MediaQuery.sizeOf(context).width * 0.65,
    ];
    return widths[index % widths.length];
  }

  double _getBulletWidth(int index) {
    final widths = [
      MediaQuery.sizeOf(context).width * 0.8,
      MediaQuery.sizeOf(context).width * 0.9,
      MediaQuery.sizeOf(context).width * 0.7,
      MediaQuery.sizeOf(context).width * 0.85,
    ];
    return widths[index % widths.length];
  }
}
