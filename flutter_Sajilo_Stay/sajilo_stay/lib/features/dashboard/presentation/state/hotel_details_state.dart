import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_stay/features/dashboard/data/repositories/hotel_repository_impl.dart';
import 'package:sajilo_stay/features/dashboard/domain/entities/hotel_details_entity.dart';

final hotelDetailsProvider =
    FutureProvider.family<HotelDetailsEntity, String>((ref, hotelId) async {
  final repository = ref.read(hotelRepositoryProvider);
  final result = await repository.getHotelDetails(hotelId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (details) => details,
  );
});
