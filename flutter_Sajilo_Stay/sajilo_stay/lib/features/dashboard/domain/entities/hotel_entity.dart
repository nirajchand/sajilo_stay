class HotelEntity {
  final String id;
  final String name;
  final String location;
  final String locationDetail;
  final double rating;
  final double pricePerNight;
  final int bedrooms;
  final int bathrooms;
  final String imageUrl;
  final String category;
  final bool isFavorite;

  const HotelEntity({
    required this.id,
    required this.name,
    required this.location,
    required this.locationDetail,
    required this.rating,
    required this.pricePerNight,
    required this.bedrooms,
    required this.bathrooms,
    required this.imageUrl,
    required this.category,
    this.isFavorite = false,
  });

  HotelEntity copyWith({bool? isFavorite}) {
    return HotelEntity(
      id: id,
      name: name,
      location: location,
      locationDetail: locationDetail,
      rating: rating,
      pricePerNight: pricePerNight,
      bedrooms: bedrooms,
      bathrooms: bathrooms,
      imageUrl: imageUrl,
      category: category,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
