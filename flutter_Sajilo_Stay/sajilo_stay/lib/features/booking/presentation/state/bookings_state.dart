import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_stay/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:sajilo_stay/features/booking/domain/entities/booking_entity.dart';

enum BookingsTabIndex { upcoming, completed }

enum BookingsStatus { initial, loading, loaded, error }

class BookingsState {
  final BookingsStatus status;
  final List<BookingEntity> upcomingBookings;
  final List<BookingEntity> completedBookings;
  final BookingsTabIndex selectedTab;
  final String? errorMessage;

  const BookingsState({
    required this.status,
    required this.upcomingBookings,
    required this.completedBookings,
    required this.selectedTab,
    this.errorMessage,
  });

  factory BookingsState.initial() => const BookingsState(
        status: BookingsStatus.initial,
        upcomingBookings: [],
        completedBookings: [],
        selectedTab: BookingsTabIndex.upcoming,
      );

  BookingsState copyWith({
    BookingsStatus? status,
    List<BookingEntity>? upcomingBookings,
    List<BookingEntity>? completedBookings,
    BookingsTabIndex? selectedTab,
    String? errorMessage,
  }) {
    return BookingsState(
      status: status ?? this.status,
      upcomingBookings: upcomingBookings ?? this.upcomingBookings,
      completedBookings: completedBookings ?? this.completedBookings,
      selectedTab: selectedTab ?? this.selectedTab,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class BookingsNotifier extends Notifier<BookingsState> {
  @override
  BookingsState build() {
    Future.microtask(() => loadBookings());
    return BookingsState.initial();
  }

  Future<void> loadBookings() async {
    state = state.copyWith(status: BookingsStatus.loading);
    final repo = ref.read(bookingRepositoryProvider);

    final upcomingResult = await repo.getUpcomingBookings();
    final completedResult = await repo.getCompletedBookings();

    BookingsState newState = state;

    upcomingResult.fold(
      (failure) => newState = newState.copyWith(
        status: BookingsStatus.error,
        errorMessage: failure.message,
      ),
      (bookings) => newState = newState.copyWith(upcomingBookings: bookings),
    );

    completedResult.fold(
      (failure) => newState = newState.copyWith(
        status: BookingsStatus.error,
        errorMessage: failure.message,
      ),
      (bookings) => newState = newState.copyWith(
        completedBookings: bookings,
        status: BookingsStatus.loaded,
      ),
    );

    state = newState;
  }

  void selectTab(BookingsTabIndex tab) {
    state = state.copyWith(selectedTab: tab);
  }

  Future<void> cancelBooking(String bookingId) async {
    // Optimistically remove from the list, then persist to the backend.
    final updated =
        state.upcomingBookings.where((b) => b.id != bookingId).toList();
    state = state.copyWith(upcomingBookings: updated);

    final repo = ref.read(bookingRepositoryProvider);
    final result = await repo.cancelBooking(bookingId);
    result.fold(
      // On failure, reload to restore the true server state.
      (_) => loadBookings(),
      (_) {},
    );
  }

  /// Submits a review to the backend. Returns `null` on success, or an error
  /// message to display.
  Future<String?> submitReview({
    required String hotelId,
    required String bookingId,
    required double rating,
    required String comment,
  }) async {
    final repo = ref.read(bookingRepositoryProvider);
    final result = await repo.submitReview(
      hotelId: hotelId,
      bookingId: bookingId,
      rating: rating,
      comment: comment,
    );
    return result.fold(
      (failure) => failure.message,
      (_) {
        final updated = state.completedBookings.map((b) {
          if (b.id == bookingId) {
            return b.copyWith(isReviewed: true, userRating: rating);
          }
          return b;
        }).toList();
        state = state.copyWith(completedBookings: updated);
        return null;
      },
    );
  }
}

final bookingsStateProvider =
    NotifierProvider<BookingsNotifier, BookingsState>(
  () => BookingsNotifier(),
);
