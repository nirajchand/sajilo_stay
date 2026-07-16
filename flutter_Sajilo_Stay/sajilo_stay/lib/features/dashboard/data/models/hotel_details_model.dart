import 'package:sajilo_stay/features/dashboard/domain/entities/hotel_details_entity.dart';
import 'package:sajilo_stay/features/dashboard/domain/entities/review_entity.dart';
import 'package:sajilo_stay/features/dashboard/domain/entities/room_entity.dart';

class HotelDetailsModel extends HotelDetailsEntity {
  const HotelDetailsModel({
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
    required super.description,
    required super.reviewCount,
    required super.galleryImages,
    required super.address,
    required super.reviews,
    required super.availableRooms,
    super.lat,
    super.lng,
  });

  // Parses the hotel detail object from the backend API response.
  // Backend sends: { _id, hotelName, description, location, gallery, rooms,
  //                  avgRating, isFavourite, bookableRooms }
  // bookableRooms: [{ _id, type, capacity, pricePerNight, images }]
  factory HotelDetailsModel.fromApiJson(
    Map<String, dynamic> json, {
    List<ReviewEntity> reviews = const [],
  }) {
    final loc = json['location'] as Map<String, dynamic>? ?? {};
    final address = (loc['address'] as String? ?? '').trim();
    final parts = address.split(',').map((p) => p.trim()).toList();
    final locationDetail = parts.isNotEmpty ? parts.last : '';
    final location = parts.length > 1
        ? parts.sublist(0, parts.length - 1).join(', ')
        : address;

    final gallery = (json['gallery'] as List<dynamic>? ?? []).cast<String>();
    final rooms = (json['rooms'] as List<dynamic>? ?? []).cast<Map<String, dynamic>>();
    final prices = rooms.map<double>((r) => (r['pricePerNight'] as num?)?.toDouble() ?? 0.0);
    final minPrice = prices.isNotEmpty ? prices.reduce((a, b) => a < b ? a : b) : 0.0;

    final rawBookable = (json['bookableRooms'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    final availableRooms = rawBookable.map((r) {
      final images = (r['images'] as List<dynamic>? ?? []).cast<String>();
      return RoomEntity(
        id: (r['_id'] ?? r['id'])?.toString() ?? '',
        name: r['type'] as String? ?? 'Room',
        imageUrl: images.isNotEmpty ? images.first : '',
        pricePerNight: (r['pricePerNight'] as num?)?.toDouble() ?? 0.0,
      );
    }).toList();

    final coords = (loc['coordinates'] as List<dynamic>? ?? []);
    final lat = coords.length >= 2 ? (coords[0] as num?)?.toDouble() : null;
    final lng = coords.length >= 2 ? (coords[1] as num?)?.toDouble() : null;

    return HotelDetailsModel(
      id: (json['_id'] ?? json['id'])?.toString() ?? '',
      name: json['hotelName'] as String? ?? '',
      location: location,
      locationDetail: locationDetail,
      rating: (json['avgRating'] as num?)?.toDouble() ?? 0.0,
      pricePerNight: minPrice,
      bedrooms: rooms.length,
      bathrooms: 1,
      imageUrl: gallery.isNotEmpty ? gallery.first : '',
      category: 'Hotel',
      isFavorite: json['isFavourite'] as bool? ?? false,
      description: json['description'] as String? ?? '',
      reviewCount: reviews.length,
      galleryImages: gallery,
      address: address,
      reviews: reviews,
      availableRooms: availableRooms,
      lat: lat,
      lng: lng,
    );
  }

  factory HotelDetailsModel.fromJson(Map<String, dynamic> json) {
    final rawReviews = json['reviews'] as List<dynamic>? ?? [];
    final rawRooms = json['availableRooms'] as List<dynamic>? ?? [];

    return HotelDetailsModel(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      locationDetail: json['locationDetail'] as String,
      rating: (json['rating'] as num).toDouble(),
      pricePerNight: (json['pricePerNight'] as num).toDouble(),
      bedrooms: json['bedrooms'] as int,
      bathrooms: json['bathrooms'] as int,
      imageUrl: json['imageUrl'] as String,
      category: json['category'] as String,
      isFavorite: json['isFavorite'] as bool? ?? false,
      description: json['description'] as String,
      reviewCount: json['reviewCount'] as int,
      galleryImages: List<String>.from(json['galleryImages'] as List),
      address: json['address'] as String,
      reviews: rawReviews.map((r) {
        final m = r as Map<String, dynamic>;
        return ReviewEntity(
          id: m['id'] as String,
          reviewerName: m['reviewerName'] as String,
          reviewerInitial: m['reviewerInitial'] as String,
          rating: (m['rating'] as num).toDouble(),
          comment: m['comment'] as String,
          date: m['date'] as String,
        );
      }).toList(),
      availableRooms: rawRooms.map((r) {
        final m = r as Map<String, dynamic>;
        return RoomEntity(
          id: m['id'] as String,
          name: m['name'] as String,
          imageUrl: m['imageUrl'] as String,
          pricePerNight: (m['pricePerNight'] as num).toDouble(),
        );
      }).toList(),
    );
  }
}
