import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_stay/features/dashboard/data/repositories/hotel_repository_impl.dart';
import 'package:sajilo_stay/features/dashboard/domain/entities/hotel_entity.dart';

enum HomeStatus { initial, loading, loaded, error }

/// Bounds for the price-per-night slider (Rs).
const double kMinFilterPrice = 1000;
const double kMaxFilterPrice = 25000;

/// User-selected hotel filters. A field at its default bound means "no limit".
class HotelFilter {
  final String? location;
  final String? roomType;
  final double minPrice;
  final double maxPrice;

  const HotelFilter({
    this.location,
    this.roomType,
    this.minPrice = kMinFilterPrice,
    this.maxPrice = kMaxFilterPrice,
  });

  bool get isActive =>
      (location != null && location!.trim().isNotEmpty) ||
      roomType != null ||
      minPrice > kMinFilterPrice ||
      maxPrice < kMaxFilterPrice;
}

class HomeState {
  final HomeStatus status;
  final List<HotelEntity> hotels;
  final String selectedCategory;
  final HotelFilter filter;
  final String? errorMessage;

  const HomeState({
    required this.status,
    required this.hotels,
    required this.selectedCategory,
    this.filter = const HotelFilter(),
    this.errorMessage,
  });

  factory HomeState.initial() => const HomeState(
    status: HomeStatus.initial,
    hotels: [],
    selectedCategory: 'All',
  );

  HomeState copyWith({
    HomeStatus? status,
    List<HotelEntity>? hotels,
    String? selectedCategory,
    HotelFilter? filter,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      hotels: hotels ?? this.hotels,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      filter: filter ?? this.filter,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
    Future.microtask(() => loadHotels());
    return HomeState.initial();
  }

  Future<void> loadHotels() async {
    state = state.copyWith(status: HomeStatus.loading);
    final repository = ref.read(hotelRepositoryProvider);
    final result = await repository.getNearbyHotels();
    result.fold(
      (failure) => state = state.copyWith(
        status: HomeStatus.error,
        errorMessage: failure.message,
      ),
      (hotels) => state = state.copyWith(
        status: HomeStatus.loaded,
        hotels: hotels,
      ),
    );
  }

  Future<void> selectCategory(String category) async {
    // Selecting a category clears any active filter to avoid conflicting queries.
    state = state.copyWith(
      selectedCategory: category,
      filter: const HotelFilter(),
      status: HomeStatus.loading,
    );
    final repository = ref.read(hotelRepositoryProvider);
    final result = await repository.getHotelsByCategory(category);
    result.fold(
      (failure) => state = state.copyWith(
        status: HomeStatus.error,
        errorMessage: failure.message,
      ),
      (hotels) => state = state.copyWith(
        status: HomeStatus.loaded,
        hotels: hotels,
      ),
    );
  }

  /// Applies the given [filter] and fetches matching hotels from the backend.
  Future<void> applyFilters(HotelFilter filter) async {
    state = state.copyWith(
      filter: filter,
      selectedCategory: 'All',
      status: HomeStatus.loading,
    );
    final repository = ref.read(hotelRepositoryProvider);
    final result = await repository.getFilteredHotels(
      city: filter.location,
      roomType: filter.roomType,
      minPrice: filter.minPrice > kMinFilterPrice ? filter.minPrice : null,
      maxPrice: filter.maxPrice < kMaxFilterPrice ? filter.maxPrice : null,
    );
    result.fold(
      (failure) => state = state.copyWith(
        status: HomeStatus.error,
        errorMessage: failure.message,
      ),
      (hotels) => state = state.copyWith(
        status: HomeStatus.loaded,
        hotels: hotels,
      ),
    );
  }

  /// Clears all filters and reloads the full hotel list.
  Future<void> clearFilters() async {
    state = state.copyWith(
      filter: const HotelFilter(),
      selectedCategory: 'All',
    );
    await loadHotels();
  }

  Future<void> toggleFavorite(String hotelId) async {
    final index = state.hotels.indexWhere((h) => h.id == hotelId);
    if (index == -1) return;
    final newValue = !state.hotels[index].isFavorite;

    // Optimistically update the UI.
    state = state.copyWith(hotels: _withFavorite(hotelId, newValue));

    // Persist to the backend so it survives app restarts.
    final repository = ref.read(hotelRepositoryProvider);
    final result = await repository.setFavourite(hotelId, newValue);
    result.fold(
      // Revert on failure.
      (_) => state = state.copyWith(hotels: _withFavorite(hotelId, !newValue)),
      (_) {},
    );
  }

  List<HotelEntity> _withFavorite(String hotelId, bool value) {
    return state.hotels
        .map((h) => h.id == hotelId ? h.copyWith(isFavorite: value) : h)
        .toList();
  }
}

final homeStateProvider = NotifierProvider<HomeNotifier, HomeState>(() {
  return HomeNotifier();
});
