import 'package:flutter/material.dart';
import 'package:sajilo_stay/core/constants/colors.dart';
import 'package:sajilo_stay/features/dashboard/domain/entities/hotel_details_entity.dart';
import 'package:sajilo_stay/features/dashboard/domain/entities/room_entity.dart';
import 'package:sajilo_stay/features/dashboard/presentation/pages/secure_payment_page.dart';

// ─── Helpers ─────────────────────────────────────────────────────────────────

const _monthsShort = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _fmtRange(DateTime a, DateTime b) =>
    '${_monthsShort[a.month - 1]} ${a.day}, ${a.year} - ${_monthsShort[b.month - 1]} ${b.day}, ${b.year}';

// ─── Page ────────────────────────────────────────────────────────────────────

class BookingDetailsPage extends StatefulWidget {
  final HotelDetailsEntity hotel;
  final RoomEntity room;
  final DateTime checkIn;
  final DateTime checkOut;

  const BookingDetailsPage({
    super.key,
    required this.hotel,
    required this.room,
    required this.checkIn,
    required this.checkOut,
  });

  @override
  State<BookingDetailsPage> createState() => _BookingDetailsPageState();
}

class _BookingDetailsPageState extends State<BookingDetailsPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _requestsCtrl = TextEditingController();
  bool _bookingForSomeoneElse = false;

  int get _nights =>
      widget.checkOut.difference(widget.checkIn).inDays;
  double get _roomTotal => widget.room.pricePerNight * _nights;
  // Taxes are included in the room price; the backend bills room × nights.
  double get _taxes => 0;
  double get _grandTotal => _roomTotal + _taxes;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _requestsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ReviewBookingCard(
              hotel: widget.hotel,
              room: widget.room,
              total: _roomTotal,
            ),
            const SizedBox(height: 20),
            _InfoRow(
              label: 'DATE',
              value: _fmtRange(widget.checkIn, widget.checkOut),
              onEdit: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 12),
            _InfoRow(
              label: 'ROOM TYPE',
              value: widget.room.name,
              onEdit: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 24),
            const _FieldLabel('Guest Information',
                isSectionTitle: true),
            const SizedBox(height: 14),
            _InputField(
              controller: _nameCtrl,
              hint: 'Ahmed Al-Rashid',
              label: 'Full Name (as per ID)',
            ),
            const SizedBox(height: 12),
            _InputField(
              controller: _emailCtrl,
              hint: 'ahmed@example.com',
              label: 'Email Address',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            _PhoneField(controller: _phoneCtrl),
            const SizedBox(height: 12),
            _InputField(
              controller: _requestsCtrl,
              hint: 'e.g. early check-in, high floor...',
              label: 'Special Requests (optional)',
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            _BookingSummaryCard(
              room: widget.room,
              nights: _nights,
              roomTotal: _roomTotal,
              taxes: _taxes,
              grandTotal: _grandTotal,
            ),
            const SizedBox(height: 20),
            _BookingForSomeoneRow(
              value: _bookingForSomeoneElse,
              onChanged: (v) =>
                  setState(() => _bookingForSomeoneElse = v ?? false),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _ProceedButton(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SecurePaymentPage(
              hotel: widget.hotel,
              room: widget.room,
              checkIn: widget.checkIn,
              checkOut: widget.checkOut,
              grandTotal: _grandTotal,
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: Container(
        color: kBackgroundColor,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Title row
              SizedBox(
                height: 52,
                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 36,
                        height: 36,
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: kSurfaceLevel1,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: kSecondaryColor, size: 16),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Booking Details',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: kSecondaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 52),
                  ],
                ),
              ),
              // Progress bar
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
                          color: kSurfaceLevel2,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: kSurfaceLevel2,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Step 1 of 3',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      color: kNeutralColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Review Booking Card ─────────────────────────────────────────────────────

class _ReviewBookingCard extends StatelessWidget {
  final HotelDetailsEntity hotel;
  final RoomEntity room;
  final double total;

  const _ReviewBookingCard({
    required this.hotel,
    required this.room,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review Booking',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: kNeutralColor,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: kSurfaceLevel1,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  hotel.imageUrl,
                  width: 68,
                  height: 68,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 68,
                    height: 68,
                    color: kSurfaceLevel2,
                    child: const Icon(Icons.hotel,
                        color: kNeutralColor, size: 28),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.name,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: kSecondaryColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            color: kNeutralColor, size: 12),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            '${hotel.location.split(',').last.trim()}, ${hotel.locationDetail}',
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11,
                              color: kNeutralColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      room.name,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        color: kNeutralColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Rs.${total.toStringAsFixed(2)} Total',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: kAccentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Info Row (date / room type) ─────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onEdit;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: kNeutralColor,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: kSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            child: const Icon(Icons.edit_outlined,
                color: kNeutralColor, size: 18),
          ),
        ],
      ),
    );
  }
}

// ─── Form Fields ─────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool isSectionTitle;
  const _FieldLabel(this.text, {this.isSectionTitle = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: isSectionTitle ? 16 : 12,
        fontWeight:
            isSectionTitle ? FontWeight.w700 : FontWeight.w500,
        color: isSectionTitle ? kSecondaryColor : kNeutralColor,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String label;
  final int maxLines;
  final TextInputType keyboardType;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.label,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 14,
            color: kSecondaryColor,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              color: kNeutralColor,
            ),
            filled: true,
            fillColor: kSurfaceLevel1,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: kNeutralColor.withValues(alpha: 0.2), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: kNeutralColor.withValues(alpha: 0.2), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: kAccentColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  const _PhoneField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FieldLabel('Phone Number'),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: kSurfaceLevel1,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: kNeutralColor.withValues(alpha: 0.2), width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                        color: kNeutralColor.withValues(alpha: 0.2),
                        width: 1),
                  ),
                ),
                child: const Text(
                  'NP +977',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: kSecondaryColor,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    color: kSecondaryColor,
                  ),
                  decoration: const InputDecoration(
                    hintText: '985764689375',
                    hintStyle: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      color: kNeutralColor,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Booking Summary ─────────────────────────────────────────────────────────

class _BookingSummaryCard extends StatelessWidget {
  final RoomEntity room;
  final int nights;
  final double roomTotal;
  final double taxes;
  final double grandTotal;

  const _BookingSummaryCard({
    required this.room,
    required this.nights,
    required this.roomTotal,
    required this.taxes,
    required this.grandTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Booking Summary',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: kSecondaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kSurfaceLevel1,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _SummaryRow(
                label:
                    'Room Price (Rs.${room.pricePerNight.toInt()} × $nights Nights)',
                value: 'Rs.${roomTotal.toStringAsFixed(2)}',
                valueColor: kSecondaryColor,
              ),
              const SizedBox(height: 10),
              _SummaryRow(
                label: 'Taxes & Fees',
                value: 'Rs.${taxes.toStringAsFixed(2)}',
                valueColor: kSecondaryColor,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(
                    height: 1,
                    color: kNeutralColor.withValues(alpha: 0.15)),
              ),
              _SummaryRow(
                label: 'Total Price',
                value: 'Rs.${grandTotal.toStringAsFixed(2)}',
                valueColor: kAccentColor,
                bold: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool bold;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: bold ? 14 : 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            color: bold ? kSecondaryColor : kNeutralColor,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: bold ? 15 : 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

// ─── Booking for someone else checkbox ───────────────────────────────────────

class _BookingForSomeoneRow extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _BookingForSomeoneRow({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: kAccentColor,
              checkColor: Colors.white,
              side: BorderSide(
                  color: kNeutralColor.withValues(alpha: 0.5), width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'I am booking for someone else',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              color: kNeutralColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Proceed Button ──────────────────────────────────────────────────────────

class _ProceedButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ProceedButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: kSurfaceLevel1,
        border: Border(
          top: BorderSide(
              color: kNeutralColor.withValues(alpha: 0.12), width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: kAccentColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Proceed to Payment',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
