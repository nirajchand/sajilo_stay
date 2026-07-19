import 'package:flutter/material.dart';
import 'package:sajilo_stay/core/constants/colors.dart';
import 'package:sajilo_stay/features/dashboard/presentation/state/home_state.dart';

/// Bottom sheet for filtering hotels by location, room type and price range.
/// Returns the selected [HotelFilter] via `Navigator.pop` when "Apply" is tapped.
class HotelFilterSheet extends StatefulWidget {
  final HotelFilter initial;
  const HotelFilterSheet({super.key, required this.initial});

  @override
  State<HotelFilterSheet> createState() => _HotelFilterSheetState();
}

class _HotelFilterSheetState extends State<HotelFilterSheet> {
  static const _roomTypes = ['Single', 'Double', 'Deluxe'];

  late final TextEditingController _locationController;
  String? _roomType;
  late RangeValues _price;

  @override
  void initState() {
    super.initState();
    _locationController =
        TextEditingController(text: widget.initial.location ?? '');
    _roomType = widget.initial.roomType;
    _price = RangeValues(widget.initial.minPrice, widget.initial.maxPrice);
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _locationController.clear();
      _roomType = null;
      _price = const RangeValues(kMinFilterPrice, kMaxFilterPrice);
    });
  }

  void _apply() {
    Navigator.of(context).pop(
      HotelFilter(
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        roomType: _roomType,
        minPrice: _price.start,
        maxPrice: _price.end,
      ),
    );
  }

  String _priceLabel(double v) =>
      v >= 1000 ? 'Rs.${(v / 1000).toStringAsFixed(v % 1000 == 0 ? 0 : 1)}k'
                : 'Rs.${v.toStringAsFixed(0)}';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: kBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: kNeutralColor.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Header
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.close,
                          color: kSecondaryColor, size: 22),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Filter',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: kSecondaryColor,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _reset,
                      child: const Text(
                        'Reset',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: kAccentColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Location
                const _Label('Select Location'),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: kSurfaceLevel1,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _locationController,
                    style: const TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      color: kSecondaryColor,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Where are you going?',
                      prefixIcon: Icon(Icons.location_on_outlined,
                          color: kNeutralColor, size: 20),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Bedroom type
                const _Label('Bedroom Type'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    for (final type in _roomTypes) ...[
                      _RoomTypeChip(
                        label: type,
                        selected: _roomType == type,
                        onTap: () => setState(
                          () => _roomType = _roomType == type ? null : type,
                        ),
                      ),
                      if (type != _roomTypes.last) const SizedBox(width: 12),
                    ],
                  ],
                ),
                const SizedBox(height: 28),

                // Price per night
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const _Label('Price per night'),
                    Text(
                      '${_priceLabel(_price.start)} - ${_priceLabel(_price.end)}',
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: kAccentColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: kAccentColor,
                    inactiveTrackColor: kSurfaceLevel2,
                    thumbColor: kAccentColor,
                    overlayColor: kAccentColor.withValues(alpha: 0.15),
                    trackHeight: 3,
                    rangeThumbShape:
                        const RoundRangeSliderThumbShape(enabledThumbRadius: 9),
                  ),
                  child: RangeSlider(
                    values: _price,
                    min: kMinFilterPrice,
                    max: kMaxFilterPrice,
                    onChanged: (v) => setState(() => _price = v),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Rs.1000',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          color: kNeutralColor,
                        )),
                    Text('Rs25K',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          color: kNeutralColor,
                        )),
                  ],
                ),
                const SizedBox(height: 28),

                // Apply
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccentColor,
                      foregroundColor: kPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _apply,
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: kSecondaryColor,
      ),
    );
  }
}

class _RoomTypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RoomTypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? kSecondaryColor : kSurfaceLevel1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? kSecondaryColor
                : kNeutralColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 14,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? kPrimaryColor : kNeutralColor,
          ),
        ),
      ),
    );
  }
}
