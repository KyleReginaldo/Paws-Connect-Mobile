import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/services/supabase_service.dart';
import '../../../core/widgets/search_field.dart';
import '../../../core/widgets/text.dart';
import '../widgets/app_bar.dart';
import '../widgets/fundraising_container.dart';
import '../widgets/home/categories_list.dart';
import '../widgets/home/promotion_container.dart';
import '../widgets/pet_container.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      endDrawer: Drawer(
        shape: RoundedRectangleBorder(),
        child: Column(
          children: [
            DrawerHeader(
              child: Column(
                children: [
                  PawsText(
                    "${supabase.auth.currentUser?.userMetadata?['role']}",
                  ),
                  PawsText('Subtitle'),
                  PawsText('Title'),
                ],
              ),
            ),
            ListTile(
              leading: Icon(LucideIcons.map),
              title: PawsText('Address'),
            ),
            ListTile(
              leading: Icon(LucideIcons.calendar),
              title: PawsText('Adoption History'),
            ),
            ListTile(
              leading: Icon(LucideIcons.bookmark),
              title: PawsText('Recent Donations'),
            ),
            Spacer(),
            ListTile(
              iconColor: Colors.redAccent,
              leading: Icon(LucideIcons.logOut),
              title: PawsText('Log Out', color: Colors.redAccent),
              onTap: () {
                supabase.auth.signOut();
              },
            ),
          ],
        ),
      ),
      appBar: HomeAppBar(
        onOpenDrawer: () {
          scaffoldKey.currentState?.openEndDrawer();
        },
      ),
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
