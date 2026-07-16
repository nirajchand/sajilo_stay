enum BookingStatus { upcoming, completed }

class BookingEntity {
  final String id;
  final String hotelId;
  final String bookingCode;
  final String hotelName;
  final String hotelImageUrl;
  final String location;
  final String checkIn;
  final String checkOut;
  final int bedrooms;
  final int bathrooms;
  final int guests;
  final BookingStatus status;
  final bool isReviewed;
  final double? userRating;

  const BookingEntity({
    required this.id,
    required this.hotelId,
    required this.bookingCode,
    required this.hotelName,
    required this.hotelImageUrl,
    required this.location,
    required this.checkIn,
    required this.checkOut,
    required this.bedrooms,
    required this.bathrooms,
    required this.guests,
    required this.status,
    this.isReviewed = false,
    this.userRating,
  });

  BookingEntity copyWith({
    bool? isReviewed,
    double? userRating,
  }) {
    return BookingEntity(
      id: id,
      hotelId: hotelId,
      bookingCode: bookingCode,
      hotelName: hotelName,
      hotelImageUrl: hotelImageUrl,
      location: location,
      checkIn: checkIn,
      checkOut: checkOut,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      guests: guests,
      status: status,
      isReviewed: isReviewed ?? this.isReviewed,
      userRating: userRating ?? this.userRating,
    );
  }
}
