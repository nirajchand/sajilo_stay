import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_stay/core/constants/colors.dart';
import 'package:sajilo_stay/core/utils/snackbar_utils.dart';
import 'package:sajilo_stay/features/booking/data/models/payment_models.dart';
import 'package:sajilo_stay/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:sajilo_stay/features/booking/presentation/pages/esewa_payment_page.dart'
    show EsewaPaymentPage, kDemoPaid;
import 'package:sajilo_stay/features/booking/presentation/state/bookings_state.dart';
import 'package:sajilo_stay/features/dashboard/domain/entities/hotel_details_entity.dart';
import 'package:sajilo_stay/features/dashboard/domain/entities/room_entity.dart';
import 'package:sajilo_stay/features/dashboard/presentation/pages/booking_confirmed_page.dart';

// ─── Page ────────────────────────────────────────────────────────────────────

class SecurePaymentPage extends ConsumerStatefulWidget {
  final HotelDetailsEntity hotel;
  final RoomEntity room;
  final DateTime checkIn;
  final DateTime checkOut;
  final double grandTotal;
  final int guests;

  const SecurePaymentPage({
    super.key,
    required this.hotel,
    required this.room,
    required this.checkIn,
    required this.checkOut,
    required this.grandTotal,
    this.guests = 1,
  });

  @override
  ConsumerState<SecurePaymentPage> createState() => _SecurePaymentPageState();
}

class _SecurePaymentPageState extends ConsumerState<SecurePaymentPage> {
  bool _processing = false;

  int get _nights => widget.checkOut.difference(widget.checkIn).inDays;

  String _confirmationCode(String bookingId) {
    final tail = bookingId.length >= 6
        ? bookingId.substring(bookingId.length - 6)
        : bookingId;
    return '#${tail.toUpperCase()}';
  }

  Future<void> _onConfirm() async {
    if (_processing) return;

    setState(() => _processing = true);
    final repo = ref.read(bookingRepositoryProvider);

    // 1. Create the booking on the backend (eSewa is the only method).
    final createResult = await repo.createBooking(
      roomId: widget.room.id,
      checkIn: widget.checkIn,
      checkOut: widget.checkOut,
      guests: widget.guests,
      paymentMethod: 'ESEWA',
    );

    if (!mounted) return;

    final created = createResult.fold<CreatedBooking?>(
      (failure) {
        SnackbarUtils.showError(context, _clean(failure.message));
        return null;
      },
      (booking) => booking,
    );

    if (created == null) {
      setState(() => _processing = false);
      return;
    }

    // 2. Get backend-signed eSewa form fields.
    final initResult = await repo.initiateEsewa(created.id);
    if (!mounted) return;

    final initiation = initResult.fold<EsewaInitiation?>(
      (failure) {
        SnackbarUtils.showError(context, _clean(failure.message));
        return null;
      },
      (data) => data,
    );

    if (initiation == null) {
      await repo.cancelBooking(created.id);
      if (!mounted) return;
      setState(() => _processing = false);
      return;
    }

    // 3. Open eSewa checkout — the page auto-posts the signed form, no
    //    extra tap needed. Spinner stays on until we return.
    final data = await Navigator.push<String?>(
      context,
      MaterialPageRoute(
        builder: (_) => EsewaPaymentPage(initiation: initiation),
      ),
    );

    if (!mounted) return;

    if (data == null) {
      // Payment cancelled / failed → discard the unpaid booking.
      await repo.cancelBooking(created.id);
      if (!mounted) return;
      setState(() => _processing = false);
      SnackbarUtils.showInfo(context, 'Payment was not completed. No booking was made.');
      return;
    }

    setState(() => _processing = true);

    if (data == kDemoPaid) {
      // User manually confirmed after seeing eSewa's success screen.
      // The redirect was blocked by the sandbox, so we confirm via the
      // demo endpoint instead of the signed-callback verify flow.
      final demoResult = await repo.demoConfirmPayment(created.id);
      if (!mounted) return;
      demoResult.fold(
        (failure) {
          setState(() => _processing = false);
          SnackbarUtils.showError(context, _clean(failure.message));
        },
        (_) => _goToConfirmed(created.id, 'eSewa', paid: true),
      );
      return;
    }

    // 4. Verify the base64 callback payload eSewa returned automatically.
    final verifyResult = await repo.verifyEsewa(data);
    if (!mounted) return;

    await verifyResult.fold(
      (failure) async {
        await repo.cancelBooking(created.id);
        if (!mounted) return;
        setState(() => _processing = false);
        SnackbarUtils.showError(context, _clean(failure.message));
      },
      (_) async => _goToConfirmed(created.id, 'eSewa', paid: true),
    );
  }

  void _goToConfirmed(String bookingId, String paymentMethod,
      {required bool paid}) {
    // Refresh the bookings tab so the new booking appears.
    ref.invalidate(bookingsStateProvider);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => BookingConfirmedPage(
          hotel: widget.hotel,
          room: widget.room,
          checkIn: widget.checkIn,
          checkOut: widget.checkOut,
          grandTotal: widget.grandTotal,
          paymentMethod: paymentMethod,
          confirmationId: _confirmationCode(bookingId),
          isPaid: paid,
        ),
      ),
    );
  }

  String _clean(String raw) {
    // Strip noisy Dio/exception prefixes for user-facing messages.
    final stripped = raw.replaceFirst('Exception: ', '');
    return stripped.length > 140 ? 'Booking failed. Please try again.' : stripped;
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
            _TotalAmountCard(
              grandTotal: widget.grandTotal,
              roomName: widget.room.name,
              nights: _nights,
            ),
            const SizedBox(height: 24),
            const Text(
              'Select Payment Method',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: kSecondaryColor,
              ),
            ),
            const SizedBox(height: 14),
            _EsewaCard(
              isSelected: true,
              onTap: () {},
            ),
            const SizedBox(height: 24),
            const _SslNotice(),
          ],
        ),
      ),
      bottomNavigationBar: _ConfirmButton(
        enabled: !_processing,
        loading: _processing,
        onTap: _onConfirm,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
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
                          'Secure Payment',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: kSecondaryColor,
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: Text(
                        'Step 2 of 3',
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
                          color: kSurfaceLevel2,
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

// ─── Total Amount Card ────────────────────────────────────────────────────────

class _TotalAmountCard extends StatelessWidget {
  final double grandTotal;
  final String roomName;
  final int nights;

  const _TotalAmountCard({
    required this.grandTotal,
    required this.roomName,
    required this.nights,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kSurfaceLevel1,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    color: kNeutralColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Rs. ${grandTotal.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: kSecondaryColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Booking for: $roomName  |  $nights ${nights == 1 ? 'Night' : 'Nights'}',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    color: kNeutralColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: kAccentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                const Icon(Icons.lock_outlined, color: kAccentColor, size: 20),
          ),
        ],
      ),
    );
  }
}

// ─── eSewa Card ───────────────────────────────────────────────────────────────

class _EsewaCard extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;

  const _EsewaCard({required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: isSelected ? kAccentColor : kSurfaceLevel2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? kAccentColor
                : kNeutralColor.withValues(alpha: 0.15),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.18)
                    : kSurfaceLevel1,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'e',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          fontStyle: FontStyle.italic,
                          color: isSelected ? Colors.white : kAccentColor,
                        ),
                      ),
                      TextSpan(
                        text: '-',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : kAccentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'eSewa',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : kSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SSL Notice ───────────────────────────────────────────────────────────────

class _SslNotice extends StatelessWidget {
  const _SslNotice();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.verified_user_outlined,
                color: kAccentColor, size: 16),
            const SizedBox(width: 8),
            const Text(
              'Protected with 256-bit SSL encryption',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: kAccentColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Your payment details are encrypted and securely processed. We do not store your full card details.',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 12,
            height: 1.65,
            color: kNeutralColor,
          ),
        ),
      ],
    );
  }
}

// ─── Confirm Button ───────────────────────────────────────────────────────────

class _ConfirmButton extends StatelessWidget {
  final bool enabled;
  final bool loading;
  final VoidCallback onTap;

  const _ConfirmButton({
    required this.enabled,
    required this.onTap,
    this.loading = false,
  });

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
          onTap: enabled ? onTap : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: (enabled || loading) ? kAccentColor : kSurfaceLevel2,
              borderRadius: BorderRadius.circular(14),
            ),
            child: loading
                ? const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Confirm Payment',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: enabled ? Colors.white : kNeutralColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
                        color: enabled ? Colors.white : kNeutralColor,
                        size: 18,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
