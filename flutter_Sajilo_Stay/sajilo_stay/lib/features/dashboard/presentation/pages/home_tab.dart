import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_stay/core/constants/colors.dart';
import 'package:sajilo_stay/core/services/storage/user_session_service.dart';
import 'package:sajilo_stay/core/utils/snackbar_utils.dart';
import 'package:sajilo_stay/features/dashboard/presentation/pages/hotel_details_page.dart';
import 'package:sajilo_stay/features/dashboard/presentation/state/home_state.dart';
import 'package:sajilo_stay/features/dashboard/presentation/state/profile_image_state.dart';
import 'package:sajilo_stay/features/dashboard/presentation/widgets/hotel_card_widget.dart';
import 'package:sajilo_stay/features/dashboard/presentation/widgets/hotel_filter_sheet.dart';

const _categories = ['All', 'KTM', 'Pokhara', 'Mustang', 'Chitwan', 'Lumbini'];

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeStateProvider);
    final session = ref.read(userSessionServiceProvider);
    final firstName =
        (session.getCurrentUserFullName() ?? 'Traveler').split(' ').first;

    return SafeArea(
      child: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HomeHeader(firstName: firstName),
                      const SizedBox(height: 20),
                      const _SearchBar(),
                      const SizedBox(height: 20),
                      _CategoryChips(
                          selectedCategory: homeState.selectedCategory),
                      const SizedBox(height: 24),
                      _SectionHeader(
                        title: 'Nearby Hotels',
                        onViewAll: () => SnackbarUtils.showInfo(
                          context,
                          'View All coming soon.',
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              if (homeState.status == HomeStatus.loading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: kAccentColor),
                  ),
                )
              else if (homeState.status == HomeStatus.error)
                SliverFillRemaining(
                  child: Center(
                    child: Text(
                      homeState.errorMessage ?? 'Something went wrong.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                )
              else
                SliverPadding(
                  // extra bottom padding so last card clears the floating button
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 96),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final hotel = homeState.hotels[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: HotelCardWidget(
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
                      childCount: homeState.hotels.length,
                    ),
                  ),
                ),
            ],
          ),

          // Floating Show Map button
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () =>
                    SnackbarUtils.showInfo(context, 'Map view coming soon.'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 14),
                  decoration: BoxDecoration(
                    color: kSurfaceLevel2,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: kNeutralColor.withValues(alpha: 0.25),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.map_outlined,
                          color: kSecondaryColor, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Show Map',
                        style:
                            Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: kSecondaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends ConsumerWidget {
  final String firstName;
  const _HomeHeader({required this.firstName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagePath = ref.watch(profileImageProvider);
    final hasImage = imagePath != null && File(imagePath).existsSync();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on, color: kNeutralColor, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Kathmandu, Nepal',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: kNeutralColor,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Hey, $firstName 👋',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: kSurfaceLevel1,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: kSecondaryColor,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: kSurfaceLevel2,
            border: Border.all(
                color: kAccentColor.withValues(alpha: 0.4), width: 1.5),
            image: hasImage
                ? DecorationImage(
                    image: FileImage(File(imagePath)),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: hasImage
              ? null
              : const Icon(Icons.person, color: kNeutralColor, size: 22),
        ),
      ],
    );
  }
}

class _SearchBar extends ConsumerWidget {
  const _SearchBar();

  Future<void> _openFilter(BuildContext context, WidgetRef ref) async {
    final current = ref.read(homeStateProvider).filter;
    final result = await showModalBottomSheet<HotelFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => HotelFilterSheet(initial: current),
    );
    if (result != null) {
      await ref.read(homeStateProvider.notifier).applyFilters(result);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasFilter = ref.watch(homeStateProvider).filter.isActive;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _openFilter(context, ref),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: kSurfaceLevel1,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const Icon(Icons.search, color: kNeutralColor, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tell us where you want to go',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: kNeutralColor,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => _openFilter(context, ref),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: hasFilter ? kAccentColor : kSurfaceLevel1,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.tune_rounded,
              color: hasFilter ? kPrimaryColor : kSecondaryColor,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryChips extends ConsumerWidget {
  final String selectedCategory;
  const _CategoryChips({required this.selectedCategory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == selectedCategory;
          return GestureDetector(
            onTap: () => ref
                .read(homeStateProvider.notifier)
                .selectCategory(category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? kSecondaryColor : kSurfaceLevel1,
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? null
                    : Border.all(
                        color: kNeutralColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
              ),
              child: Text(
                category,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: isSelected ? kPrimaryColor : kNeutralColor,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onViewAll;

  const _SectionHeader({required this.title, required this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: kSecondaryColor,
              ),
        ),
        GestureDetector(
          onTap: onViewAll,
          child: Text(
            'View All',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: kPrimaryDimColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}
