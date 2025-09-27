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
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';

import '../../../core/helper/helper.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Use read instead of watch to avoid registering this callback as a listener
      // and to ensure we only call fetch once after mount.
      if (!mounted) return;
      final repo = context.read<FundraisingRepository>();
      repo.fetchFundraisingById(widget.id);
    });
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
    Widget bodyContent;
    if (isLoading) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (errorMessage != null) {
      bodyContent = Center(child: PawsText(errorMessage));
    } else if (fundraising == null) {
      bodyContent = Center(child: PawsText('Fundraising not found'));
    } else {
      bodyContent = SingleChildScrollView(
        child: Column(
          children: [
            if (fundraising.images != null && fundraising.images!.isNotEmpty)
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
                      children: fundraising.images!.map((image) {
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
                        'created ${DateFormat('MMM dd, yyyy').format(fundraising.createdAt)}',
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
                            fundraising.raisedAmount > fundraising.targetAmount
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
                          : fundraising.raisedAmount == fundraising.targetAmount
                          ? PawsColors.success
                          : PawsColors.primary,
                    ),
                    minHeight: 8,
                    backgroundColor: PawsColors.border,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PawsText(
                        fundraising.raisedAmount >= fundraising.targetAmount
                            ? 'Recent donations'
                            : 'Recent donations',
                        fontSize: 16,
                      ),
                      if (fundraising.raisedAmount >= fundraising.targetAmount)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: PawsColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: PawsColors.success.withValues(alpha: 0.3),
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
                                e.donor.id == USER_ID
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
      );
    }

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          title: const PawsText(
            'Fundraising',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: PawsColors.textPrimary,
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
                                    'Title: ${fundraising.title}\nDescription: ${fundraising.description}\nLink: https://paws-connect-sable.vercel.app/forum-chat/${fundraising.id}',
                                files: file != null ? [file] : null,
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
