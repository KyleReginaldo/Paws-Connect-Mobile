import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:paws_connect/core/components/components.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/dependency.dart';
import 'package:paws_connect/features/favorite/provider/favorite_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/router/app_route.gr.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/theme/paws_theme.dart';
import '../../../core/widgets/text.dart';
import '../repository/favorite_repository.dart';

@RoutePage()
class FavoriteScreen extends StatefulWidget implements AutoRouteWrapper {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: sl<FavoriteRepository>(),
      child: this,
    );
  }
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late RealtimeChannel favoriteChannel;

  @override
  void initState() {
    favoriteChannel = supabase.channel(
      'public:favorites:user=eq.${USER_ID ?? ""}',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoriteRepository>().getFavorites(USER_ID ?? "");
      listenToChanges();
    });
    super.initState();
  }

  void listenToChanges() {
    favoriteChannel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'favorites',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user',
            value: USER_ID ?? "",
          ),
          callback: (payload) {
            // Check if widget is still mounted before accessing context
            if (mounted) {
              context.read<FavoriteRepository>().getFavorites(USER_ID ?? "");
            }
          },
        )
        .subscribe();
  }

  void _removeFavorite(int favoriteId) async {
    final result = await FavoriteProvider().removeFavorite(favoriteId);
    if (result.isError) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.error)));
    } else {
      if (!mounted) return;
      context.read<FavoriteRepository>().getFavorites(USER_ID ?? "");
    }
  }

  @override
  Widget build(BuildContext context) {
    final favorites = context.select(
      (FavoriteRepository repo) => repo.favorites,
    );
    return Scaffold(
      appBar: AppBar(
        title: const PawsText(
          'Favorites',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: PawsColors.textPrimary,
        ),
        centerTitle: true,
      ),
      body: favorites == null || favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/empty_fav_pet.png', width: 120),
                  PawsText(
                    "No favorites found",
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  PawsText("All of your favorite pets will appear here."),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                context.read<FavoriteRepository>().getFavorites(USER_ID ?? "");
              },
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final double maxWidth = constraints.maxWidth;
                      // minimal desired item width (adjustable)
                      const double minItemWidth = 160;
                      const double spacing = 12;
                      final int columns = (maxWidth / (minItemWidth + spacing))
                          .floor()
                          .clamp(1, 4);
                      final double itemWidth =
                          (maxWidth - (columns - 1) * spacing) / columns;

                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: List.generate(favorites.length, (index) {
                          final favorite = favorites[index];
                          final pet = favorite.pet;
                          return SizedBox(
                            width: itemWidth,
                            child: Stack(
                              children: [
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  elevation: 2,
                                  child: InkWell(
                                    onTap: () {
                                      context.router.push(
                                        PetDetailRoute(pet: pet),
                                      );
                                    },
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Image area with fixed aspect ratio
                                        AspectRatio(
                                          aspectRatio: 4 / 3,
                                          child: NetworkImageView(
                                            pet.photos.first,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            enableTapToView: false,
                                          ),
                                        ),
                                        // Text content
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            12,
                                            8,
                                            12,
                                            12,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              PawsText(
                                                pet.name,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              PawsText(
                                                pet.breed,
                                                fontSize: 12,
                                                color: PawsColors.textSecondary,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: IconButton(
                                    onPressed: () {
                                      _removeFavorite(favorite.id);
                                    },
                                    icon: Icon(
                                      Icons.favorite,
                                      color: PawsColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
              ),
            ),
    );
  }
}
