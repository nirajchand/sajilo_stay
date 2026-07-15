import 'package:flutter/material.dart';
import 'package:sajilo_stay/core/constants/colors.dart';
import 'package:sajilo_stay/features/booking/domain/entities/booking_entity.dart';

class CompletedBookingCard extends StatefulWidget {
  final BookingEntity booking;
  final Future<void> Function(
    BookingEntity booking,
    double rating,
    String comment,
  ) onSubmitReview;

  const CompletedBookingCard({
    super.key,
    required this.booking,
    required this.onSubmitReview,
  });

  @override
  State<CompletedBookingCard> createState() => _CompletedBookingCardState();
}

class _CompletedBookingCardState extends State<CompletedBookingCard> {
  double _selectedRating = 0;
  bool _submitting = false;
  final _reviewController = TextEditingController();

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedRating <= 0 || _submitting) return;
    setState(() => _submitting = true);
    await widget.onSubmitReview(
      widget.booking,
      _selectedRating,
      _reviewController.text.trim(),
    );
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BookingInfoCard(booking: widget.booking),
        if (!widget.booking.isReviewed) ...[
          const SizedBox(height: 12),
          _ReviewForm(
            selectedRating: _selectedRating,
            reviewController: _reviewController,
            submitting: _submitting,
            onStarTap: (rating) => setState(() => _selectedRating = rating),
            onSubmit: _submit,
          ),
        ],
      ],
    );
  }
}

class _BookingInfoCard extends StatelessWidget {
  final BookingEntity booking;
  const _BookingInfoCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSurfaceLevel1,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              booking.hotelImageUrl,
              width: 90,
              height: 78,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 90,
                height: 78,
                color: kSurfaceLevel2,
                child: const Center(
                  child: Icon(Icons.image_not_supported_outlined,
                      color: kNeutralColor, size: 22),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.hotelName,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: kSecondaryColor,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${booking.checkIn} – ${booking.checkOut}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: kNeutralColor,
                      ),
                ),
                const SizedBox(height: 8),
                if (booking.isReviewed)
                  _ReviewedBadge(rating: booking.userRating ?? 0)
                else
                  _StayCompletedBadge(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StayCompletedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: kAccentColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'Stay Completed',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: kAccentColor,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _ReviewedBadge extends StatelessWidget {
  final double rating;
  const _ReviewedBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) {
          return Icon(
            i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
            color: i < rating ? const Color(0xFFFACC15) : kNeutralColor,
            size: 14,
          );
        }),
        const SizedBox(width: 6),
        Text(
          'Reviewed',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: kAccentColor,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _ReviewForm extends StatelessWidget {
  final double selectedRating;
  final TextEditingController reviewController;
  final bool submitting;
  final ValueChanged<double> onStarTap;
  final VoidCallback onSubmit;

  const _ReviewForm({
    required this.selectedRating,
    required this.reviewController,
    required this.submitting,
    required this.onStarTap,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: kSurfaceLevel1,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'How was your stay?',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: kSecondaryColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              return GestureDetector(
                onTap: () => onStarTap(i + 1.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Icon(
                    i < selectedRating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: i < selectedRating
                        ? const Color(0xFFFACC15)
                        : kNeutralColor,
                    size: 34,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: reviewController,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              color: kSecondaryColor,
              fontSize: 14,
            ),
            decoration: const InputDecoration(
              hintText: 'Write your experience...',
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            maxLines: 3,
            minLines: 3,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (selectedRating > 0 && !submitting) ? onSubmit : null,
              child: submitting
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
