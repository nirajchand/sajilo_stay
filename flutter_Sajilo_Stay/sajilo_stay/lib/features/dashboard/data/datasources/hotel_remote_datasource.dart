import 'package:sajilo_stay/core/api/api_endpoints.dart';
import 'package:sajilo_stay/core/api/app_client.dart';
import 'package:sajilo_stay/features/dashboard/data/datasources/hotel_local_datasource.dart';
import 'package:sajilo_stay/features/dashboard/data/models/hotel_details_model.dart';
import 'package:sajilo_stay/features/dashboard/data/models/hotel_model.dart';
import 'package:sajilo_stay/features/dashboard/data/models/review_model.dart';
import 'package:sajilo_stay/features/dashboard/domain/entities/review_entity.dart';

// Maps the Flutter UI category chip labels to backend city search terms.
const _categoryToCity = {
  'KTM': 'Kathmandu',
  'Pokhara': 'Pokhara',
  'Mustang': 'Mustang',
  'Chitwan': 'Chitwan',
  'Lumbini': 'Lumbini',
};

class HotelRemoteDatasource implements IHotelLocalDatasource {
  final ApiClient _apiClient;

  HotelRemoteDatasource({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<HotelModel>> getNearbyHotels() async {
    final response = await _apiClient.get(ApiEndpoints.hotels);
    final data = response.data['data'] as List<dynamic>? ?? [];
    return data
        .cast<Map<String, dynamic>>()
        .map(HotelModel.fromApiJson)
        .toList();
  }

  @override
  Future<List<HotelModel>> getHotelsByCategory(String category) async {
    if (category == 'All') return getNearbyHotels();

    final city = _categoryToCity[category] ?? category;
    final response = await _apiClient.get(
      ApiEndpoints.hotels,
      queryParameters: {'city': city},
    );
    final data = response.data['data'] as List<dynamic>? ?? [];
    return data
        .cast<Map<String, dynamic>>()
        .map(HotelModel.fromApiJson)
        .toList();
  }

  @override
  Future<List<HotelModel>> getFilteredHotels({
    String? city,
    String? roomType,
    double? minPrice,
    double? maxPrice,
  }) async {
    final query = <String, dynamic>{};
    if (city != null && city.trim().isNotEmpty) query['city'] = city.trim();
    if (roomType != null && roomType.isNotEmpty) query['roomType'] = roomType;
    if (minPrice != null) query['minPrice'] = minPrice.round();
    if (maxPrice != null) query['maxPrice'] = maxPrice.round();

    final response = await _apiClient.get(
      ApiEndpoints.hotels,
      queryParameters: query.isEmpty ? null : query,
    );
    final data = response.data['data'] as List<dynamic>? ?? [];
    return data
        .cast<Map<String, dynamic>>()
        .map(HotelModel.fromApiJson)
        .toList();
  }

  @override
  Future<HotelDetailsModel> getHotelDetails(String hotelId) async {
    final response = await _apiClient.get(ApiEndpoints.hotelById(hotelId));
    final data = response.data['data'] as Map<String, dynamic>;
    final reviews = await getHotelReviews(hotelId);
    return HotelDetailsModel.fromApiJson(data, reviews: reviews);
  }

  @override
  Future<void> addFavourite(String hotelId) async {
    await _apiClient.post(
      ApiEndpoints.favourites,
      data: {'hotelId': hotelId},
    );
  }

  @override
  Future<void> removeFavourite(String hotelId) async {
    await _apiClient.delete(ApiEndpoints.favouriteById(hotelId));
  }

  Future<List<ReviewEntity>> getHotelReviews(String hotelId) async {
    try {
      final response = await _apiClient.get(ApiEndpoints.hotelReviews(hotelId));
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data
          .cast<Map<String, dynamic>>()
          .map(ReviewModel.fromApiJson)
          .toList();
    } catch (_) {
      // Reviews are non-critical for the details page — fail soft.
      return const [];
    }
  }
}
