import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_stay/core/constants/colors.dart';
import 'package:sajilo_stay/core/utils/snackbar_utils.dart';
import 'package:sajilo_stay/features/booking/domain/entities/booking_entity.dart';
import 'package:sajilo_stay/features/booking/presentation/pages/booking_detail_page.dart';
import 'package:sajilo_stay/features/booking/presentation/state/bookings_state.dart';
import 'package:sajilo_stay/features/booking/presentation/widgets/completed_booking_card.dart';
import 'package:sajilo_stay/features/booking/presentation/widgets/upcoming_booking_card.dart';

class BookingsTab extends ConsumerWidget {
  const BookingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookingsStateProvider);

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sajilo Stay',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: kNeutralColor,
                            ),
                      ),
                      const Icon(Icons.location_on_outlined,
                          color: kNeutralColor, size: 20),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Bookings',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 20),
                  _TabSwitcher(
                    selected: state.selectedTab,
                    onChanged: (tab) =>
                        ref.read(bookingsStateProvider.notifier).selectTab(tab),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          if (state.status == BookingsStatus.loading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: kAccentColor),
              ),
            )
          else if (state.status == BookingsStatus.error)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  state.errorMessage ?? 'Something went wrong.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              sliver: state.selectedTab == BookingsTabIndex.upcoming
                  ? _UpcomingSliver(
                      bookings: state.upcomingBookings,
                      onCancel: (id) {
                        ref
                            .read(bookingsStateProvider.notifier)
                            .cancelBooking(id);
                        SnackbarUtils.showInfo(
                            context, 'Booking cancelled successfully.');
                      },
                      onViewDetails: (booking) => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BookingDetailPage(
                            booking: booking,
                            onCancel: () {
                              ref
                                  .read(bookingsStateProvider.notifier)
                                  .cancelBooking(booking.id);
                              SnackbarUtils.showInfo(
                                  context, 'Booking cancelled successfully.');
                            },
                          ),
                        ),
                      ),
                    )
                  : _CompletedSliver(
                      bookings: state.completedBookings,
                      onSubmitReview: (booking, rating, comment) async {
                        final error = await ref
                            .read(bookingsStateProvider.notifier)
                            .submitReview(
                              hotelId: booking.hotelId,
                              bookingId: booking.id,
                              rating: rating,
                              comment: comment,
                            );
                        if (!context.mounted) return;
                        if (error == null) {
                          SnackbarUtils.showSuccess(
                              context, 'Thank you for your review!');
                        } else {
                          SnackbarUtils.showError(context, error);
                        }
                      },
                    ),
            ),
        ],
      ),
    );
  }
}

// ── Tab switcher ────────────────────────────────────────────────────────────

class _TabSwitcher extends StatelessWidget {
  final BookingsTabIndex selected;
  final ValueChanged<BookingsTabIndex> onChanged;

  const _TabSwitcher({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: kSurfaceLevel1,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _TabPill(
            label: 'Upcoming',
            isSelected: selected == BookingsTabIndex.upcoming,
            onTap: () => onChanged(BookingsTabIndex.upcoming),
          ),
          _TabPill(
            label: 'Completed',
            isSelected: selected == BookingsTabIndex.completed,
            onTap: () => onChanged(BookingsTabIndex.completed),
          ),
        ],
      ),
    );
  }
}

class _TabPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabPill(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? kSecondaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isSelected ? kPrimaryColor : kNeutralColor,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Upcoming list ────────────────────────────────────────────────────────────

class _UpcomingSliver extends StatelessWidget {
  final List<BookingEntity> bookings;
  final void Function(String id) onCancel;
  final void Function(BookingEntity booking) onViewDetails;

  const _UpcomingSliver({
    required this.bookings,
    required this.onCancel,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today_outlined,
                  color: kNeutralColor.withValues(alpha: 0.5), size: 48),
              const SizedBox(height: 16),
              Text(
                'No upcoming bookings',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: kNeutralColor,
                    ),
              ),
            ],
          ),
        ),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: UpcomingBookingCard(
            booking: bookings[index],
            onCancel: () => onCancel(bookings[index].id),
            onViewDetails: () => onViewDetails(bookings[index]),
          ),
        ),
        childCount: bookings.length,
      ),
    );
  }
}

// ── Completed list ───────────────────────────────────────────────────────────

class _CompletedSliver extends StatelessWidget {
  final List<BookingEntity> bookings;
  final Future<void> Function(
    BookingEntity booking,
    double rating,
    String comment,
  ) onSubmitReview;

  const _CompletedSliver({
    required this.bookings,
    required this.onSubmitReview,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline,
                  color: kNeutralColor.withValues(alpha: 0.5), size: 48),
              const SizedBox(height: 16),
              Text(
                'No completed bookings',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: kNeutralColor,
                    ),
              ),
            ],
          ),
        ),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: CompletedBookingCard(
            booking: bookings[index],
            onSubmitReview: onSubmitReview,
          ),
        ),
        childCount: bookings.length,
      ),
    );
  }
}
