import 'package:flutter/material.dart';
import 'package:sajilo_stay/core/constants/colors.dart';
import 'package:sajilo_stay/features/dashboard/domain/entities/hotel_entity.dart';

class HotelCardWidget extends StatelessWidget {
  final HotelEntity hotel;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onBookNow;
  final VoidCallback? onTap;

  const HotelCardWidget({
    super.key,
    required this.hotel,
    required this.onFavoriteToggle,
    required this.onBookNow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: kSurfaceLevel1,
          borderRadius: BorderRadius.circular(24.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HotelImage(hotel: hotel, onFavoriteToggle: onFavoriteToggle),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HotelTitleRow(hotel: hotel),
                  const SizedBox(height: 6.0),
                  _HotelLocationRow(hotel: hotel),
                  const SizedBox(height: 14.0),
                  _HotelActionRow(
                    hotel: hotel,
                    onBookNow: onBookNow,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HotelImage extends StatelessWidget {
  final HotelEntity hotel;
  final VoidCallback onFavoriteToggle;

  const _HotelImage({required this.hotel, required this.onFavoriteToggle});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 10,
          child: Image.network(
            hotel.imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: kSurfaceLevel2,
              child: const Center(
                child: Icon(Icons.image_not_supported_outlined,
                    color: kNeutralColor, size: 40),
              ),
            ),
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: onFavoriteToggle,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.28),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hotel.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: hotel.isFavorite ? kAccentColor : Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HotelTitleRow extends StatelessWidget {
  final HotelEntity hotel;
  const _HotelTitleRow({required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            hotel.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: kSecondaryColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Row(
          children: [
            const Icon(Icons.star_rounded, color: Color(0xFFFACC15), size: 16),
            const SizedBox(width: 3),
            Text(
              hotel.rating.toStringAsFixed(1),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: kSecondaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HotelLocationRow extends StatelessWidget {
  final HotelEntity hotel;
  const _HotelLocationRow({required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.location_on_outlined, color: kNeutralColor, size: 14),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            hotel.location,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: kNeutralColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _HotelActionRow extends StatelessWidget {
  final HotelEntity hotel;
  final VoidCallback onBookNow;

  const _HotelActionRow({
    required this.hotel,
    required this.onBookNow,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Rs.${hotel.pricePerNight.toInt()}',
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: kSecondaryColor,
                ),
              ),
              const TextSpan(
                text: ' /night',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: kNeutralColor,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onBookNow,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: kSecondaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Book Now',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: 12,
                color: kPrimaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
