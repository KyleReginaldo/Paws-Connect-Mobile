// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:paws_connect/core/components/components.dart';
import 'package:paws_connect/core/extension/int.ext.dart';
import 'package:paws_connect/core/router/app_route.gr.dart';
import 'package:paws_connect/features/fundraising/models/fundraising_model.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/theme/paws_theme.dart';
import '../../../core/widgets/text.dart';

class FundraisingContainer extends StatelessWidget {
  final Fundraising fundraising;
  const FundraisingContainer({super.key, required this.fundraising});

  @override
  Widget build(BuildContext context) {
    debugPrint('transformed url: ${fundraising.transformedImages}');
    return InkWell(
      onTap: () {
        context.router.push(FundraisingDetailRoute(id: fundraising.id));
      },
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.90,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: PawsColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                if (fundraising.transformedImages != null &&
                    fundraising.transformedImages!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: NetworkImageView(
                      fundraising.transformedImages![0],
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PawsText(
                        fundraising.title,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: PawsColors.textPrimary,
                      ),
                      PawsText(
                        fundraising.description,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: PawsColors.textSecondary,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      PawsText(
                        '${fundraising.raisedAmount.progress(fundraising.targetAmount).percentage}% target reached',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      PawsText(
                        timeago.format(fundraising.createdAt),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PawsText(
                  'Raised: ${fundraising.raisedAmount.displayMoney()}',
                  fontWeight: FontWeight.w500,
                ),
                PawsText(
                  'Goal: ${fundraising.targetAmount.displayMoney()}',
                  color: PawsColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
            SizedBox(height: 4),
            LinearProgressIndicator(
              value: fundraising.raisedAmount.progress(
                fundraising.targetAmount,
              ),
              backgroundColor: PawsColors.border,
              borderRadius: BorderRadius.circular(8),
            ),
          ],
        ),
      ),
    );
  }
}
