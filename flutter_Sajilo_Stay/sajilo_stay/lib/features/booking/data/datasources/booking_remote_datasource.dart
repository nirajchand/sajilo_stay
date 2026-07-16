import 'package:sajilo_stay/core/api/api_endpoints.dart';
import 'package:sajilo_stay/core/api/app_client.dart';
import 'package:sajilo_stay/features/booking/data/models/booking_model.dart';
import 'package:sajilo_stay/features/booking/data/models/payment_models.dart';

abstract class IBookingRemoteDatasource {
  Future<List<BookingModel>> getMyBookings();
  Future<CreatedBooking> createBooking({
    required String roomId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
    required String paymentMethod,
  });
  Future<EsewaInitiation> initiateEsewa(String bookingId);
  Future<void> verifyEsewa(String data);
  Future<void> demoConfirmPayment(String bookingId);
  Future<void> cancelBooking(String bookingId);
  Future<void> createReview({
    required String hotelId,
    required String bookingId,
    required int rating,
    required String comment,
  });
}

class BookingRemoteDatasource implements IBookingRemoteDatasource {
  final ApiClient _apiClient;

  BookingRemoteDatasource({required ApiClient apiClient})
      : _apiClient = apiClient;

  // Send dates at local noon to avoid timezone shifts crossing midnight,
  // then convert to UTC ISO-8601 which the backend's Zod .datetime() expects.
  String _toIso(DateTime d) =>
      DateTime(d.year, d.month, d.day, 12).toUtc().toIso8601String();

  @override
  Future<List<BookingModel>> getMyBookings() async {
    final response = await _apiClient.get(ApiEndpoints.bookings);
    final data = response.data['data'] as List<dynamic>? ?? [];
    return data
        .cast<Map<String, dynamic>>()
        // Only show bookings that are actually paid/confirmed. Exclude
        // CANCELLED and PENDING (unpaid eSewa) — a booking only counts once
        // payment succeeds.
        .where((b) {
          final status = (b['status'] as String?)?.toUpperCase();
          return status != 'CANCELLED' && status != 'PENDING';
        })
        .map(BookingModel.fromApiJson)
        .toList();
  }

  @override
  Future<CreatedBooking> createBooking({
    required String roomId,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
    required String paymentMethod,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.bookings,
      data: {
        'roomId': roomId,
        'checkIn': _toIso(checkIn),
        'checkOut': _toIso(checkOut),
        'guests': guests,
        'paymentMethod': paymentMethod,
      },
    );
    return CreatedBooking.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<EsewaInitiation> initiateEsewa(String bookingId) async {
    final response = await _apiClient.post(
      ApiEndpoints.esewaInitiate,
      data: {'bookingId': bookingId},
    );
    return EsewaInitiation.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  @override
  Future<void> verifyEsewa(String data) async {
    await _apiClient.post(
      ApiEndpoints.esewaVerify,
      data: {'data': data},
    );
  }

  @override
  Future<void> demoConfirmPayment(String bookingId) async {
    await _apiClient.post(
      ApiEndpoints.esewaDemoConfirm,
      data: {'bookingId': bookingId},
    );
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    await _apiClient.dio.patch(ApiEndpoints.cancelBooking(bookingId));
  }

  @override
  Future<void> createReview({
    required String hotelId,
    required String bookingId,
    required int rating,
    required String comment,
  }) async {
    await _apiClient.post(
      ApiEndpoints.reviews,
      data: {
        'hotelId': hotelId,
        'bookingId': bookingId,
        'rating': rating,
        if (comment.isNotEmpty) 'comment': comment,
      },
    );
  }
}
