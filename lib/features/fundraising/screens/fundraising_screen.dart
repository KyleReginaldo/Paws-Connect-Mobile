import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paws_connect/core/components/components.dart';
import 'package:paws_connect/core/extension/ext.dart';
import 'package:paws_connect/dependency.dart';
import 'package:paws_connect/features/fundraising/models/fundraising_model.dart';
import 'package:paws_connect/features/fundraising/repository/fundraising_repository.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' show RefreshTrigger;

import '../../../core/router/app_route.gr.dart';
import '../../../core/theme/paws_theme.dart';
import '../../../core/widgets/text.dart';

@RoutePage()
class FundraisingScreen extends StatefulWidget implements AutoRouteWrapper {
  const FundraisingScreen({super.key});

  @override
  State<FundraisingScreen> createState() => _FundraisingScreenState();
  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<FundraisingRepository>(),
      child: this,
    );
  }
}

class _FundraisingScreenState extends State<FundraisingScreen>
    with SingleTickerProviderStateMixin {
  final List<String> tabs = ['All', 'ONGOING', 'COMPLETE'];

  late TabController _tabController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final repo = context.read<FundraisingRepository>();
      repo.fetchFundraisings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fundraisings = context.watch<FundraisingRepository>().fundraisings;
    final isLoading = context.watch<FundraisingRepository>().isLoading;
    final errorMessage = context.watch<FundraisingRepository>().errorMessage;

    if (errorMessage != null && !isLoading && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
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
                context.read<FundraisingRepository>().fetchFundraisings();
              },
            ),
          ),
        );
      });
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        title: const Text(
          'Fundraising',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),

                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    onTap: (value) {
                      setState(() {
                        currentIndex = value;
                      });
                    },
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: PawsColors.primary,
                      boxShadow: [
                        BoxShadow(
                          color: PawsColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    indicatorPadding: const EdgeInsets.all(4),
                    labelColor: Colors.white,
                    unselectedLabelColor: PawsColors.textSecondary,
                    labelStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    dividerColor: Colors.transparent,

                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    tabs: tabs.map((tab) {
                      final index = tabs.indexOf(tab);

                      final color = index == currentIndex
                          ? Colors.white
                          : PawsColors.textSecondary;
                      return _buildCustomTab(tab, color);
                    }).toList(),
                  ),
                ),
                Container(height: 1, color: Colors.grey[200]),
              ],
            ),
          ),

          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : (errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              PawsText(
                                errorMessage,
                                textAlign: TextAlign.center,
                                color: PawsColors.textSecondary,
                              ),
                            ],
                          ),
                        )
                      : TabBarView(
                          physics: NeverScrollableScrollPhysics(),

                          controller: _tabController,
                          children: tabs.map((status) {
                            final filteredFundraisings =
                                _getFilteredFundraisings(
                                  fundraisings ?? [],
                                  status,
                                );

                            return _buildFundraisingList(filteredFundraisings);
                          }).toList(),
                        )),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTab(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: PawsText(
        label.capitalize(),
        fontSize: 12,
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  List<Fundraising> _getFilteredFundraisings(
    List<Fundraising> fundraisings,
    String status,
  ) {
    if (status == 'All') {
      return fundraisings;
    }
    return fundraisings
        .where(
          (fundraising) =>
              fundraising.status.toString().toUpperCase() ==
              status.toUpperCase(),
        )
        .toList();
  }

  Widget _buildFundraisingList(List<Fundraising> fundraisings) {
    if (fundraisings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/no_fundraising.png', width: 150),
            const SizedBox(height: 24),
            const PawsText(
              'No fundraising found',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: PawsColors.textPrimary,
            ),
            const SizedBox(height: 8),
            const PawsText(
              'Fundraising campaigns will appear here.',
              fontSize: 14,
              color: PawsColors.textSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshTrigger(
      onRefresh: () async {
        context.read<FundraisingRepository>().fetchFundraisings();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: fundraisings.length,
        itemBuilder: (context, index) {
          final fundraising = fundraisings[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  context.router.push(
                    FundraisingDetailRoute(id: fundraising.id),
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[100],
                        ),
                        child:
                            (fundraising.transformedImages == null ||
                                fundraising.transformedImages!.isEmpty)
                            ? Icon(
                                Icons.volunteer_activism_outlined,
                                size: 32,
                                color: Colors.grey[400],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: NetworkImageView(
                                  fundraising.transformedImages![0],
                                  fit: BoxFit.cover,
                                  width: 80,
                                  height: 80,
                                ),
                              ),
                      ),
                      const SizedBox(width: 8),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: PawsText(
                                    fundraising.title,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: PawsColors.textPrimary,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: fundraising.status.color.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: PawsText(
                                    fundraising.status.capitalize(),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: fundraising.status.color,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            PawsText(
                              'Raised: ${fundraising.raisedAmount.displayMoney()} of ${fundraising.targetAmount.displayMoney()}',
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: PawsColors.textSecondary,
                            ),
                            PawsText(
                              'Campaign ends on: ${DateFormat('MMM dd, yyyy').format(fundraising.endDate)}',
                              fontSize: 12,
                              color: PawsColors.textSecondary,
                            ),
                            // Sorry message for incomplete campaigns
                            if (fundraising.status.toUpperCase() ==
                                    'COMPLETE' &&
                                fundraising.raisedAmount <
                                    fundraising.targetAmount) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.orange.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: PawsText(
                                  "Thank you to everyone who has supported our campaign! While we didn't reach our goal of ${fundraising.targetAmount.displayMoney()}, we are grateful for the ${fundraising.raisedAmount.displayMoney()} raised, which will still help us ${fundraising.title.toLowerCase()}. We might take a little longer to reach the full target, but every bit helps and we are optimistic about continuing this mission. You can still support us by donating to our general fund or sharing our cause with your friends and family. Together, we can make a difference!",
                                  fontSize: 11,
                                  color: Colors.orange[800],
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
