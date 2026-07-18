import 'package:flutter/material.dart';
import 'package:sajilo_stay/core/constants/colors.dart';
import 'package:sajilo_stay/features/dashboard/domain/entities/hotel_details_entity.dart';
import 'package:sajilo_stay/features/dashboard/domain/entities/room_entity.dart';

// ─── Helpers ─────────────────────────────────────────────────────────────────

const _monthsFull = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

String _fmtDateFull(DateTime d) =>
    '${_monthsFull[d.month - 1]} ${d.day}, ${d.year}';

// ─── Page ────────────────────────────────────────────────────────────────────

class BookingConfirmedPage extends StatelessWidget {
  final HotelDetailsEntity hotel;
  final RoomEntity room;
  final DateTime checkIn;
  final DateTime checkOut;
  final double grandTotal;
  final String paymentMethod;
  final String confirmationId;
  final bool isPaid;

  const BookingConfirmedPage({
    super.key,
    required this.hotel,
    required this.room,
    required this.checkIn,
    required this.checkOut,
    required this.grandTotal,
    required this.paymentMethod,
    required this.confirmationId,
    this.isPaid = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 32, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Confirmation check circle
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: kAccentColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: kAccentColor.withValues(alpha: 0.30),
                    blurRadius: 28,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 46),
            ),
            const SizedBox(height: 22),
            const Text(
              'Pack Your Bags!',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: kSecondaryColor,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your stay at ${hotel.name} is confirmed.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                height: 1.55,
                color: kNeutralColor,
              ),
            ),
            const SizedBox(height: 28),
            // Confirmation ID card
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              decoration: BoxDecoration(
                color: kSurfaceLevel1,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'CONFIRMATION ID',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: kNeutralColor,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    confirmationId,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: kAccentColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Check-in / Check-out
            Row(
              children: [
                Expanded(
                  child: _DateCard(
                    label: 'Check-in',
                    date: _fmtDateFull(checkIn),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DateCard(
                    label: 'Check-out',
                    date: _fmtDateFull(checkOut),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Room type + Payment status
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: kSurfaceLevel1,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Room Type',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 11,
                            color: kNeutralColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          room.name,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: kSecondaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: kNeutralColor.withValues(alpha: 0.15),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Payment',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          color: kNeutralColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isPaid
                                  ? kAccentColor
                                  : const Color(0xFFFACC15),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isPaid ? 'Paid · $paymentMethod' : paymentMethod,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isPaid
                                  ? kAccentColor
                                  : const Color(0xFFFACC15),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Download PDF Voucher
            _ActionTile(
              icon: Icons.download_outlined,
              label: 'Download PDF Voucher',
              onTap: () {},
            ),
            const SizedBox(height: 10),
            // View Map & Directions
            _ActionTile(
              icon: Icons.map_outlined,
              label: 'View Map & Directions',
              onTap: () {},
            ),
            const SizedBox(height: 20),
            // Return to Home
            GestureDetector(
              onTap: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: kSecondaryColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    'Return to Home',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kPrimaryColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shield_outlined,
                    color: kNeutralColor.withValues(alpha: 0.45), size: 12),
                const SizedBox(width: 5),
                Text(
                  '256-bit Secure Transaction',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    color: kNeutralColor.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(72),
      child: Container(
        color: kBackgroundColor,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              SizedBox(
                height: 52,
                child: Row(
                  children: const [
                    SizedBox(width: 52),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Sajilo Stay',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: kSecondaryColor,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Text(
                        'Step 3 of 3',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: kNeutralColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: kAccentColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: kAccentColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: kAccentColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Date Card ────────────────────────────────────────────────────────────────

class _DateCard extends StatelessWidget {
  final String label;
  final String date;

  const _DateCard({required this.label, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: kSurfaceLevel1,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 11,
              color: kNeutralColor,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            date,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Action Tile ─────────────────────────────────────────────────────────────

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: kSurfaceLevel1,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: kAccentColor, size: 20),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: kSecondaryColor,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: kNeutralColor, size: 20),
          ],
        ),
      ),
    );
  }
}
