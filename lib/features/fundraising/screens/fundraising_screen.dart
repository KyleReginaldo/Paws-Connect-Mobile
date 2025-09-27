import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paws_connect/core/components/components.dart';
import 'package:paws_connect/core/extension/int.ext.dart';
import 'package:paws_connect/dependency.dart';
import 'package:paws_connect/features/fundraising/models/fundraising_model.dart';
import 'package:paws_connect/features/fundraising/repository/fundraising_repository.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    // Defer fetching pets until after the first frame is drawn to avoid
    // calling notifyListeners (which triggers widget rebuilds) during the
    // ancestor widget build phase.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Use read instead of watch to avoid registering this callback as a listener
      // and to ensure we only call fetch once after mount.
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

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const PawsText(
          'Fundraising',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: PawsColors.textPrimary,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black12,
      ),
      body: Column(
        children: [
          // Custom Tab Bar Container
          Container(
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  // decoration: BoxDecoration(
                  //   color: Colors.grey[100],
                  //   borderRadius: BorderRadius.circular(25),
                  // ),
                  child: TabBar(
                    controller: _tabController,
                    // isScrollable: true,
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
                    // tabAlignment: TabAlignment.start,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    tabs: tabs.map((tab) => _buildCustomTab(tab)).toList(),
                  ),
                ),
                Container(height: 1, color: Colors.grey[200]),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        PawsColors.primary,
                      ),
                    ),
                  )
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

  Widget _buildCustomTab(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: PawsText(
        label.capitalize(),
        fontSize: 12,

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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.volunteer_activism_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
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

    return RefreshIndicator(
      onRefresh: () async {
        context.read<FundraisingRepository>().fetchFundraisings();
      },
      color: PawsColors.primary,
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
                    children: [
                      // Image
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[100],
                        ),
                        child:
                            (fundraising.images == null ||
                                fundraising.images!.isEmpty)
                            ? Icon(
                                Icons.volunteer_activism_outlined,
                                size: 32,
                                color: Colors.grey[400],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: NetworkImageView(
                                  fundraising.images![0],
                                  fit: BoxFit.cover,
                                  width: 80,
                                  height: 80,
                                ),
                              ),
                      ),
                      const SizedBox(width: 8),
                      // Content
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
