import 'package:sajilo_stay/features/booking/domain/entities/booking_entity.dart';

class BookingModel extends BookingEntity {
  const BookingModel({
    required super.id,
    required super.hotelId,
    required super.bookingCode,
    required super.hotelName,
    required super.hotelImageUrl,
    required super.location,
    required super.checkIn,
    required super.checkOut,
    required super.bedrooms,
    required super.bathrooms,
    required super.guests,
    required super.status,
    super.isReviewed = false,
    super.userRating,
  });

  static const _monthsShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String _fmtDate(DateTime d) =>
      '${_monthsShort[d.month - 1]} ${d.day}, ${d.year}';

  /// Parses a populated booking from the backend.
  /// Shape: { _id, checkIn, checkOut, guests, totalPrice, status,
  ///          paymentMethod, paymentStatus,
  ///          hotelId: { hotelName, location: { address }, gallery },
  ///          roomId: { type, capacity, pricePerNight, images } }
  factory BookingModel.fromApiJson(Map<String, dynamic> json) {
    final id = (json['_id'] ?? json['id']).toString();

    final hotel = json['hotelId'] is Map<String, dynamic>
        ? json['hotelId'] as Map<String, dynamic>
        : <String, dynamic>{};
    final room = json['roomId'] is Map<String, dynamic>
        ? json['roomId'] as Map<String, dynamic>
        : <String, dynamic>{};

    // hotelId may be a populated object or a raw id string.
    final hotelId = (hotel['_id'] ?? json['hotelId'] ?? '').toString();

    final gallery = (hotel['gallery'] as List<dynamic>? ?? []).cast<String>();
    final loc = hotel['location'] as Map<String, dynamic>? ?? {};
    final capacity = (room['capacity'] as num?)?.toInt() ?? 1;

    final checkInDate = DateTime.tryParse(json['checkIn']?.toString() ?? '');
    final checkOutDate = DateTime.tryParse(json['checkOut']?.toString() ?? '');

    final rawStatus = (json['status'] as String? ?? 'CONFIRMED').toUpperCase();
    final isPast = checkOutDate != null &&
        checkOutDate.isBefore(DateTime.now());
    final uiStatus = (rawStatus == 'COMPLETED' || isPast)
        ? BookingStatus.completed
        : BookingStatus.upcoming;

    return BookingModel(
      id: id,
      hotelId: hotelId,
      bookingCode:
          '#${id.substring(id.length >= 6 ? id.length - 6 : 0).toUpperCase()}',
      hotelName: hotel['hotelName'] as String? ?? 'Hotel',
      hotelImageUrl: gallery.isNotEmpty ? gallery.first : '',
      location: loc['address'] as String? ?? '',
      checkIn: checkInDate != null ? _fmtDate(checkInDate) : '—',
      checkOut: checkOutDate != null ? _fmtDate(checkOutDate) : '—',
      bedrooms: 1,
      bathrooms: 1,
      guests: (json['guests'] as num?)?.toInt() ?? capacity,
      status: uiStatus,
      isReviewed: json['isReviewed'] as bool? ?? false,
      userRating: (json['userRating'] as num?)?.toDouble(),
    );
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      hotelId: json['hotelId'] as String? ?? '',
      bookingCode: json['bookingCode'] as String,
      hotelName: json['hotelName'] as String,
      hotelImageUrl: json['hotelImageUrl'] as String,
      location: json['location'] as String,
      checkIn: json['checkIn'] as String,
      checkOut: json['checkOut'] as String,
      bedrooms: json['bedrooms'] as int,
      bathrooms: json['bathrooms'] as int,
      guests: json['guests'] as int,
      status: json['status'] == 'upcoming'
          ? BookingStatus.upcoming
          : BookingStatus.completed,
      isReviewed: json['isReviewed'] as bool? ?? false,
      userRating: (json['userRating'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'hotelId': hotelId,
        'bookingCode': bookingCode,
        'hotelName': hotelName,
        'hotelImageUrl': hotelImageUrl,
        'location': location,
        'checkIn': checkIn,
        'checkOut': checkOut,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'guests': guests,
        'status': status == BookingStatus.upcoming ? 'upcoming' : 'completed',
        'isReviewed': isReviewed,
        'userRating': userRating,
      };
}
