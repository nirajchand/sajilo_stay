import 'package:flutter/material.dart';
import 'package:sajilo_stay/core/constants/colors.dart';
import 'package:sajilo_stay/features/booking/domain/entities/booking_entity.dart';

class UpcomingBookingCard extends StatelessWidget {
  final BookingEntity booking;
  final VoidCallback onCancel;
  final VoidCallback onViewDetails;

  const UpcomingBookingCard({
    super.key,
    required this.booking,
    required this.onCancel,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onViewDetails,
      child: Container(
        decoration: BoxDecoration(
          color: kSurfaceLevel1,
          borderRadius: BorderRadius.circular(24),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hotel image with status badge
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Image.network(
                    booking.hotelImageUrl,
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
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: kAccentColor.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: kAccentColor.withValues(alpha: 0.5), width: 1),
                    ),
                    child: const Text(
                      'Confirmed',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: kAccentColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Card body
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hotel name + booking code
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          booking.hotelName,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: kSecondaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        booking.bookingCode,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: kNeutralColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: kNeutralColor, size: 13),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          booking.location,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13,
                            color: kNeutralColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Date range
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          color: kNeutralColor, size: 13),
                      const SizedBox(width: 6),
                      Text(
                        '${booking.checkIn}  →  ${booking.checkOut}',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          color: kNeutralColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Guests
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded,
                          color: kNeutralColor, size: 13),
                      const SizedBox(width: 6),
                      Text(
                        '${booking.guests} ${booking.guests == 1 ? 'Guest' : 'Guests'}',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          color: kNeutralColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: onCancel,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: kNeutralColor.withValues(alpha: 0.35),
                                width: 1,
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: kNeutralColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: onViewDetails,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: kAccentColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                'View Details',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
