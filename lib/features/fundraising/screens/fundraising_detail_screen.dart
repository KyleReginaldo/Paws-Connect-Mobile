// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_route/auto_route.dart';
import 'package:colorful_iconify_flutter/icons/logos.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/components/components.dart';
import 'package:paws_connect/core/extension/int.ext.dart';
import 'package:paws_connect/core/router/app_route.gr.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/core/widgets/button.dart';
import 'package:paws_connect/dependency.dart';
import 'package:paws_connect/features/fundraising/repository/fundraising_repository.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' show RefreshTrigger;
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

import '../../../core/helper/helper.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/paws_theme.dart';
import '../../../core/widgets/text.dart';

@RoutePage()
class FundraisingDetailScreen extends StatefulWidget
    implements AutoRouteWrapper {
  final int id;
  const FundraisingDetailScreen({super.key, @PathParam('id') required this.id});

  @override
  State<FundraisingDetailScreen> createState() =>
      _FundraisingDetailScreenState();
  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<FundraisingRepository>(),
      child: this,
    );
  }
}

class _FundraisingDetailScreenState extends State<FundraisingDetailScreen> {
  RealtimeChannel? donationsChannel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final repo = context.read<FundraisingRepository>();
      repo.fetchFundraisingById(widget.id);
      _listenToDonations();
    });
  }

  void _listenToDonations() {
    donationsChannel = supabase.channel(
      'public:donations:fundraising=eq.${widget.id}',
    );
    donationsChannel
        ?.onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'donations',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'fundraising',
            value: widget.id,
          ),
          callback: (payload) {
            debugPrint('Donation change detected: $payload');
            if (mounted) {
              // Refresh fundraising data to get updated donations
              context.read<FundraisingRepository>().refreshFundraisingById(
                widget.id,
              );
            }
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    pageController.dispose();
    donationsChannel?.unsubscribe();
    super.dispose();
  }

  final pageController = PageController();
  int currentPage = 0;
  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<FundraisingRepository>();
    final fundraising = repo.fundraising;
    final errorMessage = repo.errorMessage;
    final isLoading = repo.isLoading;
    debugPrint('Fundraising: $fundraising');

    // Show error message with retry option for network errors
    if (errorMessage != null && !isLoading && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Clear the error message first to prevent repeated showing
        context.read<FundraisingRepository>().clearErrorMessage();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                context.read<FundraisingRepository>().fetchFundraisingById(
                  widget.id,
                );
              },
            ),
          ),
        );
      });
    }
    Widget bodyContent;
    if (isLoading) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (errorMessage != null) {
      bodyContent = Center(child: PawsText(errorMessage));
    } else if (fundraising == null) {
      bodyContent = Center(child: PawsText('Fundraising not found'));
    } else {
      bodyContent = RefreshTrigger(
        onRefresh: () async {
          context.read<FundraisingRepository>().fetchFundraisingById(widget.id);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              if (fundraising.transformedImages != null &&
                  fundraising.transformedImages!.isNotEmpty)
                Stack(
                  children: [
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.3,
                      width: MediaQuery.sizeOf(context).width,
                      child: PageView(
                        controller: pageController,
                        onPageChanged: (index) {
                          setState(() {
                            currentPage = index;
                          });
                        },
                        children: fundraising.transformedImages!.map((image) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black,
                                  Colors.transparent,
                                  Colors.transparent,
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                            height: MediaQuery.sizeOf(context).height * 0.3,
                            width: MediaQuery.sizeOf(context).width,
                            child: Opacity(
                              opacity: 0.9,
                              child: NetworkImageView(
                                image,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    if (fundraising.images!.length > 1)
                      Positioned(
                        right: 16,
                        top: 16,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: PawsText(
                            '${currentPage + 1}/${fundraising.images!.length} photos',
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              Container(
                width: MediaQuery.sizeOf(context).width,
                padding: const EdgeInsets.all(16),
                child: Column(
                  spacing: 8,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PawsText(
                          'published ${DateFormat('MMM dd, yyyy').format(fundraising.createdAt)}',
                          fontSize: 12,
                          color: PawsColors.textSecondary,
                        ),
                        if (fundraising.facebookLink != null)
                          GestureDetector(
                            onTap: () {
                              _launchUrl(fundraising.facebookLink!);
                            },
                            child: Iconify(Logos.facebook),
                          ),
                      ],
                    ),
                    PawsText(
                      fundraising.title,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    PawsText(
                      fundraising.description,
                      fontSize: 16,
                      color: PawsColors.textSecondary,
                    ),
                    SizedBox(height: 8),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PawsText(
                          'Raised: ${fundraising.raisedAmount.displayMoney()}',
                          fontWeight: FontWeight.w500,
                          color:
                              fundraising.raisedAmount >
                                  fundraising.targetAmount
                              ? PawsColors.error
                              : fundraising.raisedAmount ==
                                    fundraising.targetAmount
                              ? PawsColors.success
                              : PawsColors.textPrimary,
                        ),
                        PawsText(
                          'Goal: ${fundraising.targetAmount.displayMoney()}',
                          color: PawsColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                    LinearProgressIndicator(
                      value: fundraising.raisedAmount.progress(
                        fundraising.targetAmount,
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        fundraising.raisedAmount > fundraising.targetAmount
                            ? PawsColors.error
                            : fundraising.raisedAmount ==
                                  fundraising.targetAmount
                            ? PawsColors.success
                            : PawsColors.primary,
                      ),
                      minHeight: 8,
                      backgroundColor: PawsColors.border,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    SizedBox(height: 10),

                    // Campaign ended but target not reached message
                    if (DateTime.now().isAfter(fundraising.endDate) &&
                        fundraising.raisedAmount < fundraising.targetAmount)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  LucideIcons.heart,
                                  color: Colors.orange,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                PawsText(
                                  'Campaign Update',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            PawsText(
                              'Thank you to everyone who has supported our campaign! While we didn\'t reach our goal of ${fundraising.targetAmount.displayMoney()}, we are grateful for the ${fundraising.raisedAmount.displayMoney()} raised, which will still help us ${fundraising.title}. We might take a little longer to reach the full target, but every bit helps and we are optimistic about continuing this mission. You can still support us by donating to our general fund or sharing our cause with your friends and family. Together, we can make a difference!',
                              fontSize: 14,
                              color: PawsColors.textPrimary,
                            ),
                          ],
                        ),
                      ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        PawsText(
                          fundraising.raisedAmount >= fundraising.targetAmount
                              ? 'Recent donations'
                              : 'Recent donations',
                          fontSize: 16,
                        ),
                        if (fundraising.raisedAmount >=
                            fundraising.targetAmount)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: PawsColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: PawsColors.success.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: PawsText(
                              'COMPLETED',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: PawsColors.success,
                            ),
                          ),
                      ],
                    ),
                    fundraising.donations != null &&
                            fundraising.donations!.isNotEmpty
                        ? Column(
                            children: fundraising.donations!.map((e) {
                              return ListTile(
                                onTap: () {
                                  if (e.donor.id != USER_ID) {
                                    context.router.push(
                                      ProfileRoute(id: e.donor.id),
                                    );
                                  }
                                },
                                visualDensity: VisualDensity.compact,
                                contentPadding: EdgeInsets.zero,
                                title: PawsText(
                                  timeago.format(e.donatedAt),
                                  fontSize: 14,
                                  color: PawsColors.textPrimary,
                                ),
                                subtitle: PawsText(
                                  e.isAnonymous
                                      ? 'Anonymous'
                                      : e.donor.id == USER_ID
                                      ? '${e.donor.username} (You)'
                                      : e.donor.username,
                                  fontSize: 14,
                                  color: PawsColors.textSecondary,
                                ),
                                trailing: e.donor.id == USER_ID
                                    ? PawsText(
                                        e.amount.toDouble().displayMoney(),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: PawsColors.success,
                                      )
                                    : null,
                              );
                            }).toList(),
                          )
                        : Center(
                            child: Column(
                              children: [
                                Image.asset(
                                  'assets/images/empty_donation.png',
                                  height: 100,
                                ),
                                PawsText('No recent donations yet'),
                              ],
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Fundraising',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          centerTitle: true,
        ),
        body: bodyContent,
        bottomNavigationBar: Padding(
          padding: EdgeInsets.all(16),
          child:
              (fundraising != null &&
                      fundraising.raisedAmount >= fundraising.targetAmount) ||
                  (fundraising?.status == 'PENDING' ||
                      fundraising?.status == 'REJECTED' ||
                      fundraising?.status == 'COMPLETE' ||
                      fundraising?.status == 'CANCELLED')
              ? SizedBox()
              : Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      flex: 7,
                      child: PawsElevatedButton(
                        label: 'Donate',
                        onPressed: () {
                          if (fundraising != null) {
                            context.router.push(
                              PaymentRoute(fundraisingId: fundraising.id),
                            );
                          }
                        },
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: PawsElevatedButton(
                        label: 'Share',
                        backgroundColor: PawsColors.textSecondary,
                        onPressed: () async {
                          if (fundraising != null) {
                            XFile? file =
                                fundraising.images != null &&
                                    fundraising.images!.isNotEmpty
                                ? await urlToXFile(fundraising.images![0])
                                : null;
                            debugPrint('Thumbnail: ${file?.name}');
                            await SharePlus.instance.share(
                              ShareParams(
                                text:
                                    'Title: ${fundraising.title}\nDescription: ${fundraising.description}\nLink: https://paws-connect-rho.vercel.app/fundraising/${fundraising.id}',
                              ),
                            );
                          }
                        },
                        icon: LucideIcons.forward,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
