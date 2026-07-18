import 'package:sajilo_stay/features/dashboard/domain/entities/hotel_entity.dart';
import 'package:sajilo_stay/features/dashboard/domain/entities/review_entity.dart';
import 'package:sajilo_stay/features/dashboard/domain/entities/room_entity.dart';

class HotelDetailsEntity extends HotelEntity {
  final String description;
  final int reviewCount;
  final List<String> galleryImages;
  final String address;
  final List<ReviewEntity> reviews;
  final List<RoomEntity> availableRooms;
  final double? lat;
  final double? lng;

  const HotelDetailsEntity({
    required super.id,
    required super.name,
    required super.location,
    required super.locationDetail,
    required super.rating,
    required super.pricePerNight,
    required super.bedrooms,
    required super.bathrooms,
    required super.imageUrl,
    required super.category,
    super.isFavorite,
    required this.description,
    required this.reviewCount,
    required this.galleryImages,
    required this.address,
    required this.reviews,
    required this.availableRooms,
    this.lat,
    this.lng,
  });
}
