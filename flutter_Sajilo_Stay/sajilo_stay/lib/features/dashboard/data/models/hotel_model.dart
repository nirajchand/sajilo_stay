import 'package:sajilo_stay/features/dashboard/domain/entities/hotel_entity.dart';

class HotelModel extends HotelEntity {
  const HotelModel({
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
  });

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    return HotelModel(
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
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'location': location,
    'locationDetail': locationDetail,
    'rating': rating,
    'pricePerNight': pricePerNight,
    'bedrooms': bedrooms,
    'bathrooms': bathrooms,
    'imageUrl': imageUrl,
    'category': category,
    'isFavorite': isFavorite,
  };

  // Parses a single hotel object from the backend API response.
  // Backend sends: { _id, hotelName, description, location: { address, coordinates },
  //                  gallery, rooms, avgRating, isFavourite }
  factory HotelModel.fromApiJson(Map<String, dynamic> json) {
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
    final minPrice = prices.isNotEmpty
        ? prices.reduce((a, b) => a < b ? a : b)
        : 0.0;

    return HotelModel(
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
    );
  }

  factory HotelModel.fromEntity(HotelEntity entity) {
    return HotelModel(
      id: entity.id,
      name: entity.name,
      location: entity.location,
      locationDetail: entity.locationDetail,
      rating: entity.rating,
      pricePerNight: entity.pricePerNight,
      bedrooms: entity.bedrooms,
      bathrooms: entity.bathrooms,
      imageUrl: entity.imageUrl,
      category: entity.category,
      isFavorite: entity.isFavorite,
    );
  }
}
