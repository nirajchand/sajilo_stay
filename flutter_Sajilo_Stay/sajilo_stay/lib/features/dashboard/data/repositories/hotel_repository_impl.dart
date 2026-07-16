import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_stay/core/api/app_client.dart';
import 'package:sajilo_stay/core/error/failures.dart';
import 'package:sajilo_stay/features/dashboard/data/datasources/hotel_local_datasource.dart';
import 'package:sajilo_stay/features/dashboard/data/datasources/hotel_remote_datasource.dart';
import 'package:sajilo_stay/features/dashboard/domain/entities/hotel_details_entity.dart';
import 'package:sajilo_stay/features/dashboard/domain/entities/hotel_entity.dart';
import 'package:sajilo_stay/features/dashboard/domain/repositories/i_hotel_repository.dart';

class HotelRepositoryImpl implements IHotelRepository {
  final IHotelLocalDatasource _datasource;

  HotelRepositoryImpl({required IHotelLocalDatasource datasource})
      : _datasource = datasource;

  @override
  Future<Either<Failure, List<HotelEntity>>> getNearbyHotels() async {
    try {
      final hotels = await _datasource.getNearbyHotels();
      return Right(hotels);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<HotelEntity>>> getHotelsByCategory(
    String category,
  ) async {
    try {
      final hotels = await _datasource.getHotelsByCategory(category);
      return Right(hotels);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<HotelEntity>>> getFilteredHotels({
    String? city,
    String? roomType,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      final hotels = await _datasource.getFilteredHotels(
        city: city,
        roomType: roomType,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );
      return Right(hotels);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, HotelDetailsEntity>> getHotelDetails(
    String hotelId,
  ) async {
    try {
      final details = await _datasource.getHotelDetails(hotelId);
      return Right(details);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> setFavourite(
    String hotelId,
    bool isFavourite,
  ) async {
    try {
      if (isFavourite) {
        await _datasource.addFavourite(hotelId);
      } else {
        await _datasource.removeFavourite(hotelId);
      }
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

final hotelRemoteDatasourceProvider = Provider<IHotelLocalDatasource>((ref) {
  return HotelRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

final hotelRepositoryProvider = Provider<IHotelRepository>((ref) {
  return HotelRepositoryImpl(
    datasource: ref.read(hotelRemoteDatasourceProvider),
  );
});
