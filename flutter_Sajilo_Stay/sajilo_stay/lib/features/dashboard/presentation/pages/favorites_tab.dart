import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_stay/core/constants/colors.dart';
import 'package:sajilo_stay/core/utils/snackbar_utils.dart';
import 'package:sajilo_stay/features/dashboard/presentation/pages/hotel_details_page.dart';
import 'package:sajilo_stay/features/dashboard/presentation/state/favorites_state.dart';
import 'package:sajilo_stay/features/dashboard/presentation/state/home_state.dart';
import 'package:sajilo_stay/features/dashboard/presentation/widgets/favorite_hotel_card.dart';

class FavoritesTab extends ConsumerWidget {
  const FavoritesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = ref.watch(filteredFavoritesProvider);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Favorites',
                          style:
                              Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                        ),
                      ),
                      _IconButton(
                          icon: Icons.search,
                          onTap: () => SnackbarUtils.showInfo(
                              context, 'Search — coming soon.')),
                      const SizedBox(width: 8),
                      _IconButton(
                          icon: Icons.tune_rounded,
                          onTap: () => SnackbarUtils.showInfo(
                              context, 'Filters — coming soon.')),
                    ],
                  ),
                  const SizedBox(height: 20),
                 
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          if (filtered.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_outline,
                        color: kNeutralColor.withValues(alpha: 0.5), size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'No favorites yet',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: kNeutralColor,
                          ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final hotel = filtered[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: FavoriteHotelCard(
                        hotel: hotel,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                HotelDetailsPage(hotelId: hotel.id),
                          ),
                        ),
                        onFavoriteToggle: () => ref
                            .read(homeStateProvider.notifier)
                            .toggleFavorite(hotel.id),
                        onBookNow: () => SnackbarUtils.showInfo(
                          context,
                          'Booking ${hotel.name} — coming soon.',
                        ),
                      ),
                    );
                  },
                  childCount: filtered.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: kSurfaceLevel1,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: kSecondaryColor, size: 20),
      ),
    );
  }
}

