import 'package:sajilo_stay/features/dashboard/data/models/hotel_details_model.dart';
import 'package:sajilo_stay/features/dashboard/data/models/hotel_model.dart';

abstract class IHotelLocalDatasource {
  Future<List<HotelModel>> getNearbyHotels();
  Future<List<HotelModel>> getHotelsByCategory(String category);
  Future<List<HotelModel>> getFilteredHotels({
    String? city,
    String? roomType,
    double? minPrice,
    double? maxPrice,
  });
  Future<HotelDetailsModel> getHotelDetails(String hotelId);
  Future<void> addFavourite(String hotelId);
  Future<void> removeFavourite(String hotelId);
}

class HotelLocalDatasource implements IHotelLocalDatasource {
  static const List<Map<String, dynamic>> _mockHotels = [
    {
      'id': '1',
      'name': 'SRNTY Sahl Hasheesh',
      'location': 'Sahl Hasheesh Bay, Hurghada',
      'locationDetail': 'Egypt',
      'rating': 5.0,
      'pricePerNight': 500.0,
      'bedrooms': 6,
      'bathrooms': 8,
      'imageUrl':
          'https://images.unsplash.com/photo-1582610116397-edb72e301a4d?w=800&q=80',
      'category': 'Beach',
      'isFavorite': false,
    },
    {
      'id': '2',
      'name': 'Mountain Retreat Nagarkot',
      'location': 'Nagarkot Hill, Bhaktapur',
      'locationDetail': 'Nepal',
      'rating': 4.7,
      'pricePerNight': 320.0,
      'bedrooms': 4,
      'bathrooms': 4,
      'imageUrl':
          'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&q=80',
      'category': 'Mountain',
      'isFavorite': false,
    },
    {
      'id': '3',
      'name': 'Desert Rose Marrakech',
      'location': 'Palmeraie District, Marrakech',
      'locationDetail': 'Morocco',
      'rating': 4.9,
      'pricePerNight': 410.0,
      'bedrooms': 5,
      'bathrooms': 5,
      'imageUrl':
          'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800&q=80',
      'category': 'Desert',
      'isFavorite': false,
    },
    {
      'id': '4',
      'name': 'Lakeside Pokhara Villa',
      'location': 'Lakeside Road, Pokhara',
      'locationDetail': 'Nepal',
      'rating': 4.6,
      'pricePerNight': 280.0,
      'bedrooms': 3,
      'bathrooms': 3,
      'imageUrl':
          'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800&q=80',
      'category': 'Villa',
      'isFavorite': false,
    },
    {
      'id': '5',
      'name': 'Bali Garden Villa',
      'location': 'Seminyak, Bali',
      'locationDetail': 'Indonesia',
      'rating': 4.8,
      'pricePerNight': 650.0,
      'bedrooms': 4,
      'bathrooms': 4,
      'imageUrl':
          'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=800&q=80',
      'category': 'Villa',
      'isFavorite': false,
    },
    {
      'id': '6',
      'name': 'Santorini Cliffside Retreat',
      'location': 'Oia, Santorini',
      'locationDetail': 'Greece',
      'rating': 4.9,
      'pricePerNight': 890.0,
      'bedrooms': 2,
      'bathrooms': 2,
      'imageUrl':
          'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=800&q=80',
      'category': 'Beach',
      'isFavorite': false,
    },
    {
      'id': '7',
      'name': 'Forest Canopy Villa',
      'location': 'Ubud, Bali',
      'locationDetail': 'Indonesia',
      'rating': 4.7,
      'pricePerNight': 480.0,
      'bedrooms': 3,
      'bathrooms': 3,
      'imageUrl':
          'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800&q=80',
      'category': 'Villa',
      'isFavorite': false,
    },
    {
      'id': '8',
      'name': 'Beach Albatross Ayia Park',
      'location': 'Hurghada, Egypt',
      'locationDetail': 'Egypt',
      'rating': 4.9,
      'pricePerNight': 240.0,
      'bedrooms': 2,
      'bathrooms': 2,
      'imageUrl':
          'https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=800&q=80',
      'category': 'Beach',
      'isFavorite': false,
    },
  ];

  static const Map<String, Map<String, dynamic>> _mockDetails = {
    '1': {
      'description':
          'Experience the pinnacle of Red Sea luxury at SRNTY Sahl Hasheesh. This iconic 5-star resort sits on a pristine private bay, offering world-class dining, an expansive spa sanctuary, and beachfront suites with breathtaking sea panoramas. Every detail has been thoughtfully curated to provide an unparalleled escape for the discerning traveler.',
      'reviewCount': 2000,
      'galleryImages': [
        'https://images.unsplash.com/photo-1584132967334-10e028bd69f7?w=400&q=80',
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&q=80',
        'https://images.unsplash.com/photo-1540518614846-7eded433c457?w=400&q=80',
      ],
      'address': 'Sahl Hasheesh Bay, Hurghada, Red Sea Governorate, Egypt',
      'reviews': [
        {
          'id': 'r1',
          'reviewerName': 'Ahmed Al-Rashid',
          'reviewerInitial': 'A',
          'rating': 5.0,
          'comment':
              'The infinity pool at sunset is like nothing I\'ve ever seen. Top-notch service, highly recommended for anyone visiting Egypt.',
          'date': '2 days ago',
        },
        {
          'id': 'r2',
          'reviewerName': 'Sarah Jenkins',
          'reviewerInitial': 'S',
          'rating': 4.0,
          'comment':
              'This property is spectacular at sunset! The rooms are modern, clean, and very comfortable. Will definitely return.',
          'date': '1 week ago',
        },
      ],
      'availableRooms': [
        {
          'id': 'rm1',
          'name': 'Deluxe Single Room',
          'imageUrl':
              'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=300&q=80',
          'pricePerNight': 120.0,
        },
        {
          'id': 'rm2',
          'name': 'Superior Suite',
          'imageUrl':
              'https://images.unsplash.com/photo-1591088398332-8a7791972843?w=300&q=80',
          'pricePerNight': 350.0,
        },
      ],
    },
    '2': {
      'description':
          'Perched on a ridge overlooking the majestic Himalayas, Mountain Retreat Nagarkot offers uninterrupted panoramic views of the world\'s tallest peaks. Wake up to crimson sunrises painting Everest\'s summit while enjoying artisan coffee from your private balcony amid alpine tranquility.',
      'reviewCount': 1500,
      'galleryImages': [
        'https://images.unsplash.com/photo-1445019980597-93fa8acb246c?w=400&q=80',
        'https://images.unsplash.com/photo-1586500036706-41963de24d8b?w=400&q=80',
        'https://images.unsplash.com/photo-1540518614846-7eded433c457?w=400&q=80',
      ],
      'address': 'Nagarkot Hill Station, Bhaktapur District, Bagmati Province, Nepal',
      'reviews': [
        {
          'id': 'r1',
          'reviewerName': 'Priya Sharma',
          'reviewerInitial': 'P',
          'rating': 5.0,
          'comment':
              'The sunrise view of the Himalayas from the balcony is breathtaking! A truly magical experience I will never forget.',
          'date': '3 days ago',
        },
        {
          'id': 'r2',
          'reviewerName': 'David Kim',
          'reviewerInitial': 'D',
          'rating': 4.0,
          'comment':
              'Wonderful property with spectacular mountain views. Staff is very helpful and the local cuisine served here is excellent.',
          'date': '2 weeks ago',
        },
      ],
      'availableRooms': [
        {
          'id': 'rm1',
          'name': 'Mountain View Room',
          'imageUrl':
              'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=300&q=80',
          'pricePerNight': 320.0,
        },
        {
          'id': 'rm2',
          'name': 'Himalayan Suite',
          'imageUrl':
              'https://images.unsplash.com/photo-1591088398332-8a7791972843?w=300&q=80',
          'pricePerNight': 480.0,
        },
      ],
    },
    '3': {
      'description':
          'Desert Rose Marrakech is an enchanting riad oasis hidden within the verdant Palmeraie. Ancient Moroccan artistry meets 21st-century amenities: hand-carved plaster ceilings, a heated pool framed by date palms, and a world-class hammam. Pure Saharan magic distilled into one address.',
      'reviewCount': 1800,
      'galleryImages': [
        'https://images.unsplash.com/photo-1551882547-ff40c63fe2fa?w=400&q=80',
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&q=80',
        'https://images.unsplash.com/photo-1584132967334-10e028bd69f7?w=400&q=80',
      ],
      'address': 'Route de l\'Ourika, Palmeraie District, Marrakech, Morocco',
      'reviews': [
        {
          'id': 'r1',
          'reviewerName': 'Isabelle Fontaine',
          'reviewerInitial': 'I',
          'rating': 5.0,
          'comment':
              'Absolutely mesmerizing. The riad architecture is stunning and the hammam is one of the best I have experienced anywhere in the world.',
          'date': '5 days ago',
        },
        {
          'id': 'r2',
          'reviewerName': 'Omar Benali',
          'reviewerInitial': 'O',
          'rating': 5.0,
          'comment':
              'A true gem. The pool area is magical at night and the staff treats you like royalty. Highly recommend the desert excursion package.',
          'date': '3 weeks ago',
        },
      ],
      'availableRooms': [
        {
          'id': 'rm1',
          'name': 'Garden Riad Room',
          'imageUrl':
              'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=300&q=80',
          'pricePerNight': 410.0,
        },
        {
          'id': 'rm2',
          'name': 'Sahara Penthouse',
          'imageUrl':
              'https://images.unsplash.com/photo-1591088398332-8a7791972843?w=300&q=80',
          'pricePerNight': 620.0,
        },
      ],
    },
    '4': {
      'description':
          'Set on the serene shores of Phewa Lake, Lakeside Pokhara Villa is a tranquil retreat framed by the Annapurna range. Kayak at sunrise, trek to World Peace Stupa, then return to elegant rooms with floor-to-ceiling lake views and a rooftop infinity pool that mirrors the sky.',
      'reviewCount': 1200,
      'galleryImages': [
        'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&q=80',
        'https://images.unsplash.com/photo-1445019980597-93fa8acb246c?w=400&q=80',
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&q=80',
      ],
      'address': 'Lakeside Road, Baidam, Pokhara-6, Gandaki Province, Nepal',
      'reviews': [
        {
          'id': 'r1',
          'reviewerName': 'Rina Thapa',
          'reviewerInitial': 'R',
          'rating': 5.0,
          'comment':
              'The lake view from our balcony was simply stunning. Best breakfast I have ever had with fresh local ingredients. Perfect escape!',
          'date': '1 day ago',
        },
        {
          'id': 'r2',
          'reviewerName': 'James O\'Brien',
          'reviewerInitial': 'J',
          'rating': 4.0,
          'comment':
              'Great location steps from the lake. Rooms are beautiful and the rooftop pool is a highlight. Staff are very accommodating.',
          'date': '1 week ago',
        },
      ],
      'availableRooms': [
        {
          'id': 'rm1',
          'name': 'Lake View Room',
          'imageUrl':
              'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=300&q=80',
          'pricePerNight': 280.0,
        },
        {
          'id': 'rm2',
          'name': 'Annapurna Suite',
          'imageUrl':
              'https://images.unsplash.com/photo-1591088398332-8a7791972843?w=300&q=80',
          'pricePerNight': 420.0,
        },
      ],
    },
    '5': {
      'description':
          'Bali Garden Villa in Seminyak is the ultimate tropical sanctuary: five-star dining steps from the surf, infinity pools that flow into the Indian Ocean horizon, and open-air suites wrapped in fragrant frangipani gardens. This is Bali as it was always meant to be experienced.',
      'reviewCount': 3200,
      'galleryImages': [
        'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=400&q=80',
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&q=80',
        'https://images.unsplash.com/photo-1584132967334-10e028bd69f7?w=400&q=80',
      ],
      'address': 'Jl. Kayu Cendana No. 9, Seminyak, Kuta, Bali 80361, Indonesia',
      'reviews': [
        {
          'id': 'r1',
          'reviewerName': 'Yuki Tanaka',
          'reviewerInitial': 'Y',
          'rating': 5.0,
          'comment':
              'Paradise on earth! The pool villa is gorgeous and private. We watched the sunset from the rooftop every evening. Truly unforgettable.',
          'date': '4 days ago',
        },
        {
          'id': 'r2',
          'reviewerName': 'Laura Mendez',
          'reviewerInitial': 'L',
          'rating': 5.0,
          'comment':
              'Flawless from start to finish. The butler service is incredible and the in-villa dining rivals any restaurant. We will be back!',
          'date': '2 weeks ago',
        },
      ],
      'availableRooms': [
        {
          'id': 'rm1',
          'name': 'Garden Pool Villa',
          'imageUrl':
              'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=300&q=80',
          'pricePerNight': 650.0,
        },
        {
          'id': 'rm2',
          'name': 'Ocean Front Suite',
          'imageUrl':
              'https://images.unsplash.com/photo-1591088398332-8a7791972843?w=300&q=80',
          'pricePerNight': 950.0,
        },
      ],
    },
    '6': {
      'description':
          'Carved into the volcanic cliffs of Oia, Santorini Cliffside Retreat redefines the iconic caldera experience. Cave-hewn suites with heated private plunge pools, gourmet Greek cuisine, and the world\'s most photographed sunset are yours to discover at this extraordinary Aegean hideaway.',
      'reviewCount': 2800,
      'galleryImages': [
        'https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=400&q=80',
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&q=80',
        'https://images.unsplash.com/photo-1584132967334-10e028bd69f7?w=400&q=80',
      ],
      'address': 'Oia Village, Santorini, Cyclades, South Aegean, Greece',
      'reviews': [
        {
          'id': 'r1',
          'reviewerName': 'Nikos Papadopoulos',
          'reviewerInitial': 'N',
          'rating': 5.0,
          'comment':
              'The best hotel I have ever stayed in. The plunge pool overlooking the caldera at sunset is an experience I will carry forever.',
          'date': '6 days ago',
        },
        {
          'id': 'r2',
          'reviewerName': 'Emily Watson',
          'reviewerInitial': 'E',
          'rating': 5.0,
          'comment':
              'Truly breathtaking. Every corner of this property is photogenic. The breakfast delivered to our terrace was a dream.',
          'date': '3 weeks ago',
        },
      ],
      'availableRooms': [
        {
          'id': 'rm1',
          'name': 'Cave Suite',
          'imageUrl':
              'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=300&q=80',
          'pricePerNight': 890.0,
        },
        {
          'id': 'rm2',
          'name': 'Caldera Infinity Villa',
          'imageUrl':
              'https://images.unsplash.com/photo-1591088398332-8a7791972843?w=300&q=80',
          'pricePerNight': 1450.0,
        },
      ],
    },
    '7': {
      'description':
          'Forest Canopy Villa in Ubud immerses you in the timeless beauty of Bali\'s sacred jungle. Teak-and-stone villas perch above a rushing river gorge, surrounded by emerald rice terraces and ancient temple bells. Yoga at dawn, healing spa rituals, and farm-to-table cuisine complete this soulful retreat.',
      'reviewCount': 1600,
      'galleryImages': [
        'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=400&q=80',
        'https://images.unsplash.com/photo-1540541338287-41700207dee6?w=400&q=80',
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&q=80',
      ],
      'address': 'Jl. Raya Sanggingan No. 88, Ubud, Gianyar, Bali 80571, Indonesia',
      'reviews': [
        {
          'id': 'r1',
          'reviewerName': 'Sofia Reyes',
          'reviewerInitial': 'S',
          'rating': 5.0,
          'comment':
              'Waking up to the sound of the jungle and a misty gorge below is pure magic. The spa treatments are extraordinary. Highly recommended!',
          'date': '2 days ago',
        },
        {
          'id': 'r2',
          'reviewerName': 'Marcus Lee',
          'reviewerInitial': 'M',
          'rating': 4.0,
          'comment':
              'A unique and immersive experience in the heart of Ubud. The rice terrace walk guided by the staff was a highlight of our trip.',
          'date': '10 days ago',
        },
      ],
      'availableRooms': [
        {
          'id': 'rm1',
          'name': 'Jungle River Room',
          'imageUrl':
              'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=300&q=80',
          'pricePerNight': 480.0,
        },
        {
          'id': 'rm2',
          'name': 'Treetop Villa',
          'imageUrl':
              'https://images.unsplash.com/photo-1591088398332-8a7791972843?w=300&q=80',
          'pricePerNight': 720.0,
        },
      ],
    },
    '8': {
      'description':
          'Beach Albatross Ayia Park is a sun-drenched haven on the legendary shores of the Red Sea. Dive into crystal-clear coral gardens, unwind at the beachfront pool bar, and savor fresh seafood as the sun melts into turquoise waters. An effortlessly joyful getaway for families and couples alike.',
      'reviewCount': 2100,
      'galleryImages': [
        'https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=400&q=80',
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&q=80',
        'https://images.unsplash.com/photo-1584132967334-10e028bd69f7?w=400&q=80',
      ],
      'address': 'El Dahar District, Hurghada, Red Sea Governorate, Egypt',
      'reviews': [
        {
          'id': 'r1',
          'reviewerName': 'Fatima Hassan',
          'reviewerInitial': 'F',
          'rating': 5.0,
          'comment':
              'The snorkeling right off the beach is incredible. Super clean rooms and the beach bar makes the best cocktails. Perfect holiday!',
          'date': '1 day ago',
        },
        {
          'id': 'r2',
          'reviewerName': 'Tom Bradley',
          'reviewerInitial': 'T',
          'rating': 4.0,
          'comment':
              'Great value for a Red Sea resort. The coral reef is outstanding and the kids loved every minute. Staff very friendly and attentive.',
          'date': '4 days ago',
        },
      ],
      'availableRooms': [
        {
          'id': 'rm1',
          'name': 'Sea Breeze Room',
          'imageUrl':
              'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=300&q=80',
          'pricePerNight': 240.0,
        },
        {
          'id': 'rm2',
          'name': 'Coral Bay Suite',
          'imageUrl':
              'https://images.unsplash.com/photo-1591088398332-8a7791972843?w=300&q=80',
          'pricePerNight': 380.0,
        },
      ],
    },
  };

  @override
  Future<List<HotelModel>> getNearbyHotels() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockHotels.map((e) => HotelModel.fromJson(e)).toList();
  }

  @override
  Future<List<HotelModel>> getHotelsByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (category == 'All') {
      return _mockHotels.map((e) => HotelModel.fromJson(e)).toList();
    }
    return _mockHotels
        .where((h) => h['category'] == category)
        .map((e) => HotelModel.fromJson(e))
        .toList();
  }

  @override
  Future<List<HotelModel>> getFilteredHotels({
    String? city,
    String? roomType,
    double? minPrice,
    double? maxPrice,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockHotels
        .where((h) {
          final loc = (h['location'] as String).toLowerCase();
          final price = (h['pricePerNight'] as num).toDouble();
          if (city != null &&
              city.trim().isNotEmpty &&
              !loc.contains(city.trim().toLowerCase())) {
            return false;
          }
          if (minPrice != null && price < minPrice) return false;
          if (maxPrice != null && price > maxPrice) return false;
          return true;
        })
        .map((e) => HotelModel.fromJson(e))
        .toList();
  }

  @override
  Future<HotelDetailsModel> getHotelDetails(String hotelId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final base = _mockHotels.firstWhere(
      (h) => h['id'] == hotelId,
      orElse: () => throw Exception('Hotel not found: $hotelId'),
    );
    final detail = _mockDetails[hotelId] ??
        (throw Exception('Hotel details not found: $hotelId'));
    return HotelDetailsModel.fromJson({...base, ...detail});
  }

  @override
  Future<void> addFavourite(String hotelId) async {
    // Mock datasource has no persistence — no-op.
  }

  @override
  Future<void> removeFavourite(String hotelId) async {
    // Mock datasource has no persistence — no-op.
  }
}
