import 'package:flutter/material.dart';
import 'package:sajilo_stay/core/constants/colors.dart';
import 'package:sajilo_stay/features/booking/domain/entities/booking_entity.dart';

class BookingDetailPage extends StatelessWidget {
  final BookingEntity booking;
  final VoidCallback onCancel;

  const BookingDetailPage({
    super.key,
    required this.booking,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kSurfaceLevel1,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: kSecondaryColor, size: 16),
          ),
        ),
        title: const Text(
          'Booking Details',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: kSecondaryColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image
            _HeroImage(booking: booking),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hotel name + status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          booking.hotelName,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: kSecondaryColor,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: kAccentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: kAccentColor.withValues(alpha: 0.45),
                              width: 1),
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
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: kNeutralColor, size: 14),
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
                  const SizedBox(height: 24),
                  // Booking code card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 18),
                    decoration: BoxDecoration(
                      color: kSurfaceLevel1,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'BOOKING ID',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: kNeutralColor,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          booking.bookingCode,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: kAccentColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Check-in / Check-out row
                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          label: 'Check-in',
                          value: booking.checkIn,
                          icon: Icons.login_rounded,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _InfoCard(
                          label: 'Check-out',
                          value: booking.checkOut,
                          icon: Icons.logout_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Guests card
                  _InfoCard(
                    label: 'Guests',
                    value:
                        '${booking.guests} ${booking.guests == 1 ? 'Guest' : 'Guests'}',
                    icon: Icons.person_outline_rounded,
                    fullWidth: true,
                  ),
                  const SizedBox(height: 24),
                  // Section: What's included
                  const _SectionTitle('Stay Info'),
                  const SizedBox(height: 12),
                  _StayInfoRow(booking: booking),
                  const SizedBox(height: 28),
                  // Cancel booking button
                  GestureDetector(
                    onTap: () {
                      onCancel();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: kNeutralColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Cancel Booking',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: kNeutralColor,
                          ),
                        ),
                      ),
                    ),
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

// ─── Hero Image ───────────────────────────────────────────────────────────────

class _HeroImage extends StatelessWidget {
  final BookingEntity booking;
  const _HeroImage({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: 220,
          child: Image.network(
            booking.hotelImageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: kSurfaceLevel2,
              child: const Center(
                child: Icon(Icons.image_not_supported_outlined,
                    color: kNeutralColor, size: 48),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.6),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 14,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: kAccentColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: kAccentColor.withValues(alpha: 0.5), width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: kAccentColor, size: 12),
                const SizedBox(width: 4),
                Text(
                  booking.location.split(',').first.trim().toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: kAccentColor,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Info Card ────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool fullWidth;

  const _InfoCard({
    required this.label,
    required this.value,
    required this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: kSurfaceLevel1,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: kAccentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: kAccentColor, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 11,
                  color: kNeutralColor,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: kSecondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Stay Info Row ────────────────────────────────────────────────────────────

class _StayInfoRow extends StatelessWidget {
  final BookingEntity booking;
  const _StayInfoRow({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurfaceLevel1,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _StayInfoItem(
            icon: Icons.bed_outlined,
            label: 'Bedrooms',
            value: '${booking.bedrooms}',
          ),
          _Divider(),
          _StayInfoItem(
            icon: Icons.bathtub_outlined,
            label: 'Bathrooms',
            value: '${booking.bathrooms}',
          ),
          _Divider(),
          _StayInfoItem(
            icon: Icons.people_outline_rounded,
            label: 'Capacity',
            value: '${booking.guests} pax',
          ),
        ],
      ),
    );
  }
}

class _StayInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StayInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: kAccentColor, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: kSecondaryColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 11,
              color: kNeutralColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: kNeutralColor.withValues(alpha: 0.15),
    );
  }
}

// ─── Section Title ────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: kSecondaryColor,
      ),
    );
  }
}
