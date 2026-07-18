import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:sajilo_stay/core/constants/colors.dart';
import 'package:sajilo_stay/core/utils/snackbar_utils.dart';
import 'package:sajilo_stay/features/booking/domain/entities/booking_entity.dart';
import 'package:sajilo_stay/features/booking/presentation/state/bookings_state.dart';
import 'package:sajilo_stay/features/dashboard/domain/entities/hotel_details_entity.dart';
import 'package:sajilo_stay/features/dashboard/domain/entities/review_entity.dart';
import 'package:sajilo_stay/features/dashboard/domain/entities/room_entity.dart';
import 'package:sajilo_stay/features/dashboard/presentation/pages/booking_details_page.dart';
import 'package:sajilo_stay/features/dashboard/presentation/state/hotel_details_state.dart';

// ─── Helpers ─────────────────────────────────────────────────────────────────

const _months = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];
const _monthsShort = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _fmtDate(DateTime d) =>
    '${_monthsShort[d.month - 1]} ${d.day}, ${d.year}';

String _fmtRange(DateTime a, DateTime b) =>
    '${_monthsShort[a.month - 1]} ${a.day} - ${_monthsShort[b.month - 1]} ${b.day}, ${b.year}';

// ─── Page ────────────────────────────────────────────────────────────────────

class HotelDetailsPage extends ConsumerStatefulWidget {
  final String hotelId;
  const HotelDetailsPage({super.key, required this.hotelId});

  @override
  ConsumerState<HotelDetailsPage> createState() => _HotelDetailsPageState();
}

class _HotelDetailsPageState extends ConsumerState<HotelDetailsPage> {
  bool _descExpanded = false;
  DateTime? _checkIn;
  DateTime? _checkOut;
  DateTime _displayMonth = DateTime(DateTime.now().year, DateTime.now().month);
  RoomEntity? _selectedRoom;

  int get _nights {
    if (_checkIn == null || _checkOut == null) return 0;
    return _checkOut!.difference(_checkIn!).inDays;
  }

  void _showCalendarSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CalendarBottomSheet(
        initialCheckIn: _checkIn,
        initialCheckOut: _checkOut,
        initialMonth: _displayMonth,
        onConfirm: (checkIn, checkOut) {
          setState(() {
            _checkIn = checkIn;
            _checkOut = checkOut;
          });
        },
      ),
    );
  }

  void _bookNow(BuildContext context, HotelDetailsEntity hotel) {
    if (_checkIn == null || _checkOut == null) {
      SnackbarUtils.showInfo(context, 'Please select check-in and check-out dates.');
      return;
    }
    if (_selectedRoom == null) {
      SnackbarUtils.showInfo(context, 'Please select a room from Available Rooms.');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingDetailsPage(
          hotel: hotel,
          room: _selectedRoom!,
          checkIn: _checkIn!,
          checkOut: _checkOut!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detailsAsync = ref.watch(hotelDetailsProvider(widget.hotelId));

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
          'Sajilo Stay',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: kSecondaryColor,
          ),
        ),
        centerTitle: true,
      ),
      body: detailsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: kAccentColor)),
        error: (_, __) => const Center(
          child: Text('Unable to load hotel details.',
              style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans', color: kNeutralColor)),
        ),
        data: (hotel) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeroImage(hotel: hotel),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _NameRatingRow(hotel: hotel),
                    const SizedBox(height: 20),
                    _DescriptionSection(
                      description: hotel.description,
                      expanded: _descExpanded,
                      onToggle: () =>
                          setState(() => _descExpanded = !_descExpanded),
                    ),
                    const SizedBox(height: 24),
                    _GallerySection(hotel: hotel),
                    const SizedBox(height: 24),
                    _LocationSection(hotel: hotel),
                    const SizedBox(height: 24),
                    _RoomsSection(
                      hotel: hotel,
                      selectedRoom: _selectedRoom,
                      onRoomSelected: (room) =>
                          setState(() => _selectedRoom = room),
                    ),
                    const SizedBox(height: 24),
                    _ReviewsSection(hotel: hotel, hotelId: widget.hotelId),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: detailsAsync.when<Widget?>(
        data: (hotel) => _BookingBar(
          hotel: hotel,
          selectedRoom: _selectedRoom,
          nights: _nights,
          checkIn: _checkIn,
          checkOut: _checkOut,
          onCalendarTap: () => _showCalendarSheet(context),
          onBookNow: () => _bookNow(context, hotel),
        ),
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }
}

// ─── Hero Image ──────────────────────────────────────────────────────────────

class _HeroImage extends StatelessWidget {
  final HotelDetailsEntity hotel;
  const _HeroImage({required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: 220,
          child: Image.network(
            hotel.imageUrl,
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
                  Colors.black.withValues(alpha: 0.65),
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
                  '${hotel.location.split(',').last.trim().toUpperCase()}, ${hotel.locationDetail.toUpperCase()}',
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

// ─── Name + Rating ───────────────────────────────────────────────────────────

class _NameRatingRow extends StatelessWidget {
  final HotelDetailsEntity hotel;
  const _NameRatingRow({required this.hotel});

  @override
  Widget build(BuildContext context) {
    final reviewLabel = hotel.reviewCount >= 1000
        ? '${(hotel.reviewCount / 1000).toStringAsFixed(0)}K Reviews'
        : '${hotel.reviewCount} Reviews';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hotel.name,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: kSecondaryColor,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star_rounded, color: Color(0xFFFACC15), size: 18),
            const SizedBox(width: 5),
            Text(
              hotel.rating.toStringAsFixed(1),
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: kSecondaryColor,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '($reviewLabel)',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                color: kNeutralColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Description ─────────────────────────────────────────────────────────────

class _DescriptionSection extends StatelessWidget {
  final String description;
  final bool expanded;
  final VoidCallback onToggle;
  static const int _limit = 120;

  const _DescriptionSection({
    required this.description,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isLong = description.length > _limit;
    final shown = expanded || !isLong
        ? description
        : '${description.substring(0, _limit)}...';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Description'),
        const SizedBox(height: 10),
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              height: 1.65,
              color: kNeutralColor,
            ),
            children: [
              TextSpan(text: shown),
              if (isLong)
                WidgetSpan(
                  child: GestureDetector(
                    onTap: onToggle,
                    child: Text(
                      expanded ? '  Show Less' : '  Read More',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kAccentColor,
                      ),
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

// ─── Gallery ─────────────────────────────────────────────────────────────────

class _GallerySection extends StatelessWidget {
  final HotelDetailsEntity hotel;
  const _GallerySection({required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeaderRow(
            title: 'Gallery', actionLabel: 'View All', onAction: () {}),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: hotel.galleryImages.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, index) => ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                hotel.galleryImages[index],
                width: 130,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 130,
                  color: kSurfaceLevel2,
                  child: const Icon(Icons.image_not_supported_outlined,
                      color: kNeutralColor),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Location ────────────────────────────────────────────────────────────────

class _LocationSection extends StatelessWidget {
  final HotelDetailsEntity hotel;
  const _LocationSection({required this.hotel});

  @override
  Widget build(BuildContext context) {
    final hasCoords = hotel.lat != null && hotel.lng != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Location'),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: double.infinity,
            height: 180,
            child: hasCoords
                ? FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(hotel.lat!, hotel.lng!),
                      initialZoom: 14.0,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.sajilostay.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(hotel.lat!, hotel.lng!),
                            child: const Icon(
                              Icons.location_pin,
                              color: kAccentColor,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Container(
                    color: kSurfaceLevel1,
                    child: const Center(
                      child: Icon(Icons.map_outlined,
                          color: kNeutralColor, size: 40),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.location_on_outlined, color: kNeutralColor, size: 14),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                hotel.address,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  color: kNeutralColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Available Rooms (selectable) ────────────────────────────────────────────

class _RoomsSection extends StatelessWidget {
  final HotelDetailsEntity hotel;
  final RoomEntity? selectedRoom;
  final ValueChanged<RoomEntity> onRoomSelected;

  const _RoomsSection({
    required this.hotel,
    required this.selectedRoom,
    required this.onRoomSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Available Rooms'),
        const SizedBox(height: 12),
        SizedBox(
          height: 170,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: hotel.availableRooms.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              final room = hotel.availableRooms[index];
              final isSelected = selectedRoom?.id == room.id;
              return GestureDetector(
                onTap: () => onRoomSelected(room),
                child: _RoomCard(room: room, isSelected: isSelected),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RoomCard extends StatelessWidget {
  final RoomEntity room;
  final bool isSelected;
  const _RoomCard({required this.room, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 160,
      decoration: BoxDecoration(
        color: kSurfaceLevel1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? kAccentColor : Colors.transparent,
          width: 2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  room.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: kSurfaceLevel2,
                    child: const Center(
                        child: Icon(Icons.hotel, color: kNeutralColor, size: 32)),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: kAccentColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 14),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.name,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: kSecondaryColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  'Rs.${room.pricePerNight.toInt()}/night',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: kAccentColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Calendar Bottom Sheet ────────────────────────────────────────────────────

class _CalendarBottomSheet extends StatefulWidget {
  final DateTime? initialCheckIn;
  final DateTime? initialCheckOut;
  final DateTime initialMonth;
  final void Function(DateTime checkIn, DateTime checkOut) onConfirm;

  const _CalendarBottomSheet({
    this.initialCheckIn,
    this.initialCheckOut,
    required this.initialMonth,
    required this.onConfirm,
  });

  @override
  State<_CalendarBottomSheet> createState() => _CalendarBottomSheetState();
}

class _CalendarBottomSheetState extends State<_CalendarBottomSheet> {
  DateTime? _checkIn;
  DateTime? _checkOut;
  late DateTime _displayMonth;

  @override
  void initState() {
    super.initState();
    _checkIn = widget.initialCheckIn;
    _checkOut = widget.initialCheckOut;
    _displayMonth = widget.initialMonth;
  }

  void _onDateTap(DateTime date) {
    setState(() {
      final today = DateTime.now();
      final d = DateTime(date.year, date.month, date.day);
      final t = DateTime(today.year, today.month, today.day);
      if (d.isBefore(t)) return;
      if (_checkIn == null || (_checkIn != null && _checkOut != null)) {
        _checkIn = d;
        _checkOut = null;
      } else if (d.isAfter(_checkIn!)) {
        _checkOut = d;
      } else {
        _checkIn = d;
        _checkOut = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool canConfirm = _checkIn != null && _checkOut != null;

    return Container(
      decoration: const BoxDecoration(
        color: kSurfaceLevel1,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: kNeutralColor.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Header row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  'Select Dates',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: kSecondaryColor,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: kSurfaceLevel2,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.close, color: kNeutralColor, size: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _NavButton(
                icon: Icons.chevron_left,
                onTap: () => setState(() => _displayMonth =
                    DateTime(_displayMonth.year, _displayMonth.month - 1)),
              ),
              const SizedBox(width: 16),
              Text(
                '${_months[_displayMonth.month - 1]} ${_displayMonth.year}',
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kSecondaryColor,
                ),
              ),
              const SizedBox(width: 16),
              _NavButton(
                icon: Icons.chevron_right,
                onTap: () => setState(() => _displayMonth =
                    DateTime(_displayMonth.year, _displayMonth.month + 1)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Day headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                  .map((d) => SizedBox(
                        width: 36,
                        child: Center(
                          child: Text(
                            d,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: kNeutralColor,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Calendar grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _CalendarGrid(
              displayMonth: _displayMonth,
              checkIn: _checkIn,
              checkOut: _checkOut,
              onDateTap: _onDateTap,
            ),
          ),
          const SizedBox(height: 14),
          // Selected range label
          if (_checkIn != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  color: kSurfaceLevel2,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.date_range_outlined,
                        color: kAccentColor, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      _checkOut != null
                          ? _fmtRange(_checkIn!, _checkOut!)
                          : '${_fmtDate(_checkIn!)} → select check-out',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: kSecondaryColor,
                      ),
                    ),
                    if (_checkOut != null) ...[
                      const Spacer(),
                      Text(
                        '${_checkOut!.difference(_checkIn!).inDays} nights',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: kAccentColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          // Confirm button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: GestureDetector(
              onTap: canConfirm
                  ? () {
                      widget.onConfirm(_checkIn!, _checkOut!);
                      Navigator.of(context).pop();
                    }
                  : null,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: canConfirm ? kAccentColor : kSurfaceLevel2,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    'Confirm Dates',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: canConfirm ? Colors.white : kNeutralColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: kSurfaceLevel2,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: kSecondaryColor, size: 18),
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final DateTime displayMonth;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final ValueChanged<DateTime> onDateTap;

  const _CalendarGrid({
    required this.displayMonth,
    required this.checkIn,
    required this.checkOut,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(displayMonth.year, displayMonth.month, 1);
    final daysInMonth =
        DateTime(displayMonth.year, displayMonth.month + 1, 0).day;
    // Sunday = 0 in our S M T W T F S grid; Flutter weekday: Mon=1 … Sun=7
    final offset = firstDay.weekday % 7;
    final today = DateTime.now();
    final todayNorm =
        DateTime(today.year, today.month, today.day);

    final cells = <int?>[
      ...List<int?>.filled(offset, null),
      ...List<int?>.generate(daysInMonth, (i) => i + 1),
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    final rows = <Widget>[];
    for (int r = 0; r < cells.length ~/ 7; r++) {
      final rowCells = cells.sublist(r * 7, r * 7 + 7);
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: rowCells.map((day) {
          if (day == null) return const SizedBox(width: 36, height: 36);
          final date = DateTime(displayMonth.year, displayMonth.month, day);
          final isPast = date.isBefore(todayNorm);
          final isCheckIn = checkIn != null && date == checkIn;
          final isCheckOut = checkOut != null && date == checkOut;
          final inRange = checkIn != null &&
              checkOut != null &&
              date.isAfter(checkIn!) &&
              date.isBefore(checkOut!);

          Color bg = Colors.transparent;
          Color textColor = isPast ? kNeutralColor.withValues(alpha: 0.35) : kNeutralColor;

          if (isCheckIn || isCheckOut) {
            bg = kAccentColor;
            textColor = Colors.white;
          } else if (inRange) {
            bg = kAccentColor.withValues(alpha: 0.2);
            textColor = kSecondaryColor;
          }

          return GestureDetector(
            onTap: isPast ? null : () => onDateTap(date),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: bg,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: (isCheckIn || isCheckOut)
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: textColor,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ));
      rows.add(const SizedBox(height: 6));
    }

    return Column(children: rows);
  }
}

// ─── Reviews ─────────────────────────────────────────────────────────────────

class _ReviewsSection extends ConsumerWidget {
  final HotelDetailsEntity hotel;
  final String hotelId;
  const _ReviewsSection({required this.hotel, required this.hotelId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewLabel = hotel.reviewCount >= 1000
        ? '${(hotel.reviewCount / 1000).toStringAsFixed(0)}K Reviews'
        : '${hotel.reviewCount} Reviews';

    // A user may review each completed stay separately. Prefer an un-reviewed
    // completed booking for this hotel so a repeat guest can review again;
    // fall back to a reviewed one to show the "already reviewed" note.
    final bookingsState = ref.watch(bookingsStateProvider);
    BookingEntity? unreviewedStay;
    BookingEntity? reviewedStay;
    for (final booking in bookingsState.completedBookings) {
      if (booking.hotelId != hotelId) continue;
      if (!booking.isReviewed) {
        unreviewedStay = booking;
        break;
      }
      reviewedStay ??= booking;
    }
    final completedStay = unreviewedStay ?? reviewedStay;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeaderRow(
            title: 'Reviews', actionLabel: 'View All', onAction: () {}),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.star_rounded, color: Color(0xFFFACC15), size: 18),
            const SizedBox(width: 5),
            Text(
              '${hotel.rating.toStringAsFixed(1)}  ($reviewLabel)',
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: kSecondaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Review composer / status — only shown to guests with a completed stay.
        if (completedStay != null && !completedStay.isReviewed) ...[
          _HotelReviewComposer(
            onSubmit: (rating, comment) async {
              final error =
                  await ref.read(bookingsStateProvider.notifier).submitReview(
                        hotelId: hotelId,
                        bookingId: completedStay.id,
                        rating: rating.toDouble(),
                        comment: comment,
                      );
              if (!context.mounted) return false;
              if (error == null) {
                // Pull the freshly added review into the list.
                ref.invalidate(hotelDetailsProvider(hotelId));
                SnackbarUtils.showSuccess(
                    context, 'Thank you for your review!');
                return true;
              }
              SnackbarUtils.showError(context, error);
              return false;
            },
          ),
          const SizedBox(height: 16),
        ] else if (completedStay != null && completedStay.isReviewed) ...[
          _AlreadyReviewedNote(rating: completedStay.userRating ?? 0),
          const SizedBox(height: 16),
        ],
        if (hotel.reviews.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No reviews yet. Be the first to share your experience.',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                color: kNeutralColor.withValues(alpha: 0.8),
              ),
            ),
          )
        else
          ...hotel.reviews.map(
            (review) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ReviewCard(review: review),
            ),
          ),
      ],
    );
  }
}

// ─── Review composer (hotel details) ─────────────────────────────────────────

class _HotelReviewComposer extends StatefulWidget {
  /// Returns true when the review was accepted, so the form can reset.
  final Future<bool> Function(int rating, String comment) onSubmit;
  const _HotelReviewComposer({required this.onSubmit});

  @override
  State<_HotelReviewComposer> createState() => _HotelReviewComposerState();
}

class _HotelReviewComposerState extends State<_HotelReviewComposer> {
  int _rating = 0;
  bool _submitting = false;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating <= 0 || _submitting) return;
    setState(() => _submitting = true);
    final ok = await widget.onSubmit(_rating, _controller.text.trim());
    if (!mounted) return;
    setState(() {
      _submitting = false;
      if (ok) {
        _rating = 0;
        _controller.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: kSurfaceLevel1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kAccentColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'You stayed here — how was it?',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: kSecondaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(5, (i) {
              return GestureDetector(
                onTap: () => setState(() => _rating = i + 1),
                child: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    i < _rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: const Color(0xFFFACC15),
                    size: 30,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              color: kSecondaryColor,
              fontSize: 13,
            ),
            decoration: const InputDecoration(
              hintText: 'Write your experience (optional)...',
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            maxLines: 3,
            minLines: 2,
            maxLength: 500,
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (_rating > 0 && !_submitting) ? _submit : null,
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text('Submit Review'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlreadyReviewedNote extends StatelessWidget {
  final double rating;
  const _AlreadyReviewedNote({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: kSurfaceLevel1,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_rounded, color: kAccentColor, size: 18),
          const SizedBox(width: 8),
          Text(
            'You reviewed this stay',
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kSecondaryColor,
            ),
          ),
          const Spacer(),
          _StarRow(rating: rating),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewEntity review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSurfaceLevel1,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                    color: kSurfaceLevel2, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    review.reviewerInitial,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: kAccentColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.reviewerName,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: kSecondaryColor,
                        )),
                    Text(review.date,
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          color: kNeutralColor,
                        )),
                  ],
                ),
              ),
              _StarRow(rating: review.rating),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review.comment,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12,
              height: 1.6,
              color: kNeutralColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  final double rating;
  const _StarRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        return Icon(
          i < rating.round()
              ? Icons.star_rounded
              : Icons.star_outline_rounded,
          color: const Color(0xFFFACC15),
          size: 14,
        );
      }),
    );
  }
}

// ─── Booking Bar ─────────────────────────────────────────────────────────────

class _BookingBar extends StatelessWidget {
  final HotelDetailsEntity hotel;
  final RoomEntity? selectedRoom;
  final int nights;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final VoidCallback onCalendarTap;
  final VoidCallback onBookNow;

  const _BookingBar({
    required this.hotel,
    required this.selectedRoom,
    required this.nights,
    required this.onCalendarTap,
    required this.onBookNow,
    this.checkIn,
    this.checkOut,
  });

  @override
  Widget build(BuildContext context) {
    final double price = selectedRoom != null && nights > 0
        ? selectedRoom!.pricePerNight * nights
        : (selectedRoom?.pricePerNight ?? hotel.pricePerNight);

    final bool hasDates = checkIn != null && checkOut != null;
    final String dateLabel = hasDates
        ? _fmtRange(checkIn!, checkOut!)
        : checkIn != null
            ? '${_fmtDate(checkIn!)} → ?'
            : 'Tap to select dates';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: kSurfaceLevel1,
        border: Border(
            top: BorderSide(
                color: kNeutralColor.withValues(alpha: 0.12), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: onCalendarTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    color: hasDates ? kAccentColor : kNeutralColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        hasDates
                            ? 'Rs.${price.toStringAsFixed(2)}'
                            : 'Starting from Rs.${price.toInt()}',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: kSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateLabel,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 11,
                          color: hasDates ? kAccentColor : kNeutralColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onBookNow,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  color: kAccentColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared helpers ──────────────────────────────────────────────────────────

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

class _SectionHeaderRow extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  const _SectionHeaderRow({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _SectionTitle(title),
        GestureDetector(
          onTap: onAction,
          child: Text(
            actionLabel,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kPrimaryDimColor,
            ),
          ),
        ),
      ],
    );
  }
}
