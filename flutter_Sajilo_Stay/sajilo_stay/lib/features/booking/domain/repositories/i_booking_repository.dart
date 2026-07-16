import 'package:dartz/dartz.dart';
import 'package:sajilo_stay/core/error/failures.dart';
import 'package:sajilo_stay/features/booking/data/models/payment_models.dart';
import 'package:sajilo_stay/features/booking/domain/entities/booking_entity.dart';

abstract class IBookingRepository {
  Future<Either<Failure, List<BookingEntity>>> getUpcomingBookings();
  Future<Either<Failure, List<BookingEntity>>> getCompletedBookings();
  Future<Either<Failure, Unit>> cancelBooking(String bookingId);
  Future<Either<Failure, Unit>> submitReview({
    required String hotelId,
    required String bookingId,
    required double rating,
    required String comment,
  });

  // ── Booking + payment flow ─────────────────────────────────────────────────
  Future<Either<Failure, CreatedBooking>> createBooking({
    required String roomId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
    required String paymentMethod,
  });
  Future<Either<Failure, EsewaInitiation>> initiateEsewa(String bookingId);
  Future<Either<Failure, Unit>> verifyEsewa(String data);
  Future<Either<Failure, Unit>> demoConfirmPayment(String bookingId);
}
