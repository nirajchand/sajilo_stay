import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_stay/core/api/app_client.dart';
import 'package:sajilo_stay/core/error/failures.dart';
import 'package:sajilo_stay/features/booking/data/datasources/booking_remote_datasource.dart';
import 'package:sajilo_stay/features/booking/data/models/payment_models.dart';
import 'package:sajilo_stay/features/booking/domain/entities/booking_entity.dart';
import 'package:sajilo_stay/features/booking/domain/repositories/i_booking_repository.dart';

class BookingRepositoryImpl implements IBookingRepository {
  final IBookingRemoteDatasource _datasource;

  BookingRepositoryImpl({required IBookingRemoteDatasource datasource})
      : _datasource = datasource;

  @override
  Future<Either<Failure, List<BookingEntity>>> getUpcomingBookings() async {
    try {
      final bookings = await _datasource.getMyBookings();
      return Right(
        bookings.where((b) => b.status == BookingStatus.upcoming).toList(),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BookingEntity>>> getCompletedBookings() async {
    try {
      final bookings = await _datasource.getMyBookings();
      return Right(
        bookings.where((b) => b.status == BookingStatus.completed).toList(),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> cancelBooking(String bookingId) async {
    try {
      await _datasource.cancelBooking(bookingId);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> submitReview({
    required String hotelId,
    required String bookingId,
    required double rating,
    required String comment,
  }) async {
    try {
      await _datasource.createReview(
        hotelId: hotelId,
        bookingId: bookingId,
        rating: rating.round(),
        comment: comment,
      );
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: _readableError(e)));
    }
  }

  @override
  Future<Either<Failure, CreatedBooking>> createBooking({
    required String roomId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
    required String paymentMethod,
  }) async {
    try {
      final created = await _datasource.createBooking(
        roomId: roomId,
        checkIn: checkIn,
        checkOut: checkOut,
        guests: guests,
        paymentMethod: paymentMethod,
      );
      return Right(created);
    } catch (e) {
      return Left(ServerFailure(message: _readableError(e)));
    }
  }

  @override
  Future<Either<Failure, EsewaInitiation>> initiateEsewa(
      String bookingId) async {
    try {
      final initiation = await _datasource.initiateEsewa(bookingId);
      return Right(initiation);
    } catch (e) {
      return Left(ServerFailure(message: _readableError(e)));
    }
  }

  @override
  Future<Either<Failure, Unit>> verifyEsewa(String data) async {
    try {
      await _datasource.verifyEsewa(data);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: _readableError(e)));
    }
  }

  @override
  Future<Either<Failure, Unit>> demoConfirmPayment(String bookingId) async {
    try {
      await _datasource.demoConfirmPayment(bookingId);
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(message: _readableError(e)));
    }
  }

  String _readableError(Object e) {
    // Prefer the backend's `message` field so users see the real reason
    // (e.g. "Payment signature verification failed") instead of a raw dump.
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] is String) {
        return data['message'] as String;
      }
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return 'Cannot reach the server. Check your connection.';
      }
      return e.message ?? 'Something went wrong';
    }
    final text = e.toString();
    return text.isEmpty ? 'Something went wrong' : text;
  }
}

final bookingRemoteDatasourceProvider =
    Provider<IBookingRemoteDatasource>((ref) {
  return BookingRemoteDatasource(apiClient: ref.read(apiClientProvider));
});

final bookingRepositoryProvider = Provider<IBookingRepository>((ref) {
  return BookingRepositoryImpl(
    datasource: ref.read(bookingRemoteDatasourceProvider),
  );
});
