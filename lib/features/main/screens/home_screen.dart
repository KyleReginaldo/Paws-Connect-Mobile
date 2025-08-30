import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/search_field.dart';
import '../../../core/widgets/text.dart';
import '../widgets/app_bar.dart';
import '../widgets/fundraising_container.dart';
import '../widgets/home/categories_list.dart';
import '../widgets/home/promotion_container.dart';
import '../widgets/pet_container.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PawsSearchBar(hintText: 'Search for pets...'),
            PromotionContainer(),
            PawsText('Category', fontSize: 16, fontWeight: FontWeight.w500),
            CategoriesList(),
            // PawsDivider(thickness: 2),
            PawsText(
              'Recently added',
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 10,
                children: List.generate(3, (index) {
                  return PetContainer();
                }),
              ),
            ),
            PawsText('Fundraising', fontSize: 16, fontWeight: FontWeight.w500),
            SingleChildScrollView(
              physics: PageScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 10,
                children: List.generate(3, (index) {
                  return FundraisingContainer();
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
