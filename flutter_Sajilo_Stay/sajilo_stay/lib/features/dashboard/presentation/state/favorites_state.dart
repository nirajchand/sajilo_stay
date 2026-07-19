import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_stay/features/dashboard/domain/entities/hotel_entity.dart';
import 'package:sajilo_stay/features/dashboard/presentation/state/home_state.dart';

enum FavoritesFilter { all, hotels, villas }

class FavoritesState {
  final FavoritesFilter selectedFilter;

  const FavoritesState({this.selectedFilter = FavoritesFilter.all});

  FavoritesState copyWith({FavoritesFilter? selectedFilter}) {
    return FavoritesState(
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }
}

class FavoritesNotifier extends Notifier<FavoritesState> {
  @override
  FavoritesState build() => const FavoritesState();

  void selectFilter(FavoritesFilter filter) {
    state = state.copyWith(selectedFilter: filter);
  }
}

final favoritesStateProvider =
    NotifierProvider<FavoritesNotifier, FavoritesState>(
  () => FavoritesNotifier(),
);

final filteredFavoritesProvider = Provider<List<HotelEntity>>((ref) {
  final hotels = ref.watch(homeStateProvider).hotels;
  final filter = ref.watch(favoritesStateProvider).selectedFilter;
  final allFavorites = hotels.where((h) => h.isFavorite).toList();

  switch (filter) {
    case FavoritesFilter.hotels:
      return allFavorites.where((h) => h.category != 'Villa').toList();
    case FavoritesFilter.villas:
      return allFavorites.where((h) => h.category == 'Villa').toList();
    case FavoritesFilter.all:
      return allFavorites;
  }
});
