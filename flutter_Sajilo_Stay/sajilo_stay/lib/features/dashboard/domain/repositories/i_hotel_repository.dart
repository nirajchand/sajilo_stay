import 'package:dartz/dartz.dart';
import 'package:sajilo_stay/core/error/failures.dart';
import 'package:sajilo_stay/features/dashboard/domain/entities/hotel_details_entity.dart';
import 'package:sajilo_stay/features/dashboard/domain/entities/hotel_entity.dart';

abstract class IHotelRepository {
  Future<Either<Failure, List<HotelEntity>>> getNearbyHotels();
  Future<Either<Failure, List<HotelEntity>>> getHotelsByCategory(String category);
  Future<Either<Failure, List<HotelEntity>>> getFilteredHotels({
    String? city,
    String? roomType,
    double? minPrice,
    double? maxPrice,
  });
  Future<Either<Failure, HotelDetailsEntity>> getHotelDetails(String hotelId);
  Future<Either<Failure, Unit>> setFavourite(String hotelId, bool isFavourite);
}
