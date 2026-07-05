import { Request, Response } from 'express';
import mongoose from 'mongoose';
import * as bookingService from '../services/booking.service.js';
import * as esewa from '../services/esewa.service.js';
import { transformBooking } from '../utils/image.util.js';

function isValidObjectId(id: string): boolean {
	return mongoose.Types.ObjectId.isValid(id);
}

export class PaymentController {
	/**
	 * Build the signed eSewa form fields for a PENDING eSewa booking.
	 * The client posts these to eSewa's hosted payment form.
	 */
	async initiateEsewa(req: Request, res: Response) {
		try {
			const { bookingId } = req.body as { bookingId?: string };

			if (!bookingId || !isValidObjectId(bookingId)) {
				return res.status(400).json({ success: false, message: 'Invalid booking id' });
			}

			const booking = await bookingService.getBookingByIdRaw(bookingId);
			if (!booking) {
				return res.status(404).json({ success: false, message: 'Booking not found' });
			}

			if (booking.userId.toString() !== req.user!.userId) {
				return res.status(403).json({ success: false, message: 'Forbidden' });
			}

			if (booking.paymentMethod !== 'ESEWA') {
				return res
					.status(400)
					.json({ success: false, message: 'Booking is not an eSewa payment' });
			}

			if (booking.paymentStatus === 'PAID') {
				return res.status(400).json({ success: false, message: 'Booking is already paid' });
			}

			if (!booking.transactionUuid) {
				return res
					.status(400)
					.json({ success: false, message: 'Booking is missing a transaction reference' });
			}

			const fields = esewa.buildPaymentFields(booking.transactionUuid, booking.totalPrice);

			return res.status(200).json({
				success: true,
				message: 'eSewa payment initiated',
				data: {
					formUrl: esewa.getFormUrl(),
					fields,
				},
			});
		} catch (error: any) {
			return res.status(400).json({ success: false, message: error.message });
		}
	}

	/**
	 * Landing pages eSewa redirects the browser to after checkout. The Flutter
	 * WebView intercepts these by path (and reads the `data` query param), so
	 * the body is only a human-readable fallback. They must be reachable real
	 * URLs — eSewa rejects unreachable/non-standard hosts and cancels the
	 * payment, so we point its success_url/failure_url here.
	 */
	/**
	 * Demo-only: confirm a PENDING eSewa booking as PAID without a real
	 * callback payload. Used when the RC sandbox redirect is blocked but
	 * the payment screen was shown, so the demo flow can continue.
	 */
	async demoConfirm(req: Request, res: Response) {
		try {
			const { bookingId } = req.body as { bookingId?: string };
			if (!bookingId || !isValidObjectId(bookingId)) {
				return res.status(400).json({ success: false, message: 'Invalid booking id' });
			}
			const booking = await bookingService.getBookingByIdRaw(bookingId);
			if (!booking) {
				return res.status(404).json({ success: false, message: 'Booking not found' });
			}
			if (booking.userId.toString() !== req.user!.userId) {
				return res.status(403).json({ success: false, message: 'Forbidden' });
			}
			const updated = await bookingService.markBookingPayment(booking._id!.toString(), {
				status: 'CONFIRMED',
				paymentStatus: 'PAID',
				paymentRef: 'DEMO-' + Date.now(),
			});
			return res.status(200).json({
				success: true,
				message: 'Booking confirmed (demo)',
				data: transformBooking(updated, req),
			});
		} catch (error: any) {
			return res.status(400).json({ success: false, message: error.message });
		}
	}

	esewaSuccessPage(_req: Request, res: Response) {
		res
			.status(200)
			.type('html')
			.send(
				'<!DOCTYPE html><html><head><meta name="viewport" content="width=device-width, initial-scale=1"></head><body style="font-family:sans-serif;text-align:center;padding-top:80px;color:#1c281e"><h3>Payment successful</h3><p>Returning to the app…</p></body></html>'
			);
	}

	esewaFailurePage(_req: Request, res: Response) {
		res
			.status(200)
			.type('html')
			.send(
				'<!DOCTYPE html><html><head><meta name="viewport" content="width=device-width, initial-scale=1"></head><body style="font-family:sans-serif;text-align:center;padding-top:80px;color:#1c281e"><h3>Payment not completed</h3><p>Returning to the app…</p></body></html>'
			);
	}

	/**
	 * Verify the base64 `data` payload eSewa returns on success, then confirm
	 * the booking and mark it paid.
	 */
	async verifyEsewa(req: Request, res: Response) {
		try {
			const { data } = req.body as { data?: string };
			console.log('[eSewa verify] raw data length:', data?.length ?? 0);
			if (!data) {
				return res.status(400).json({ success: false, message: 'Missing payment data' });
			}

			let callback: esewa.EsewaCallbackData;
			try {
				callback = esewa.decodeCallbackData(data);
			} catch (err) {
				console.error('[eSewa verify] decode failed:', err);
				return res.status(400).json({ success: false, message: 'Malformed payment data' });
			}
			console.log('[eSewa verify] decoded callback:', JSON.stringify(callback));

			if (callback.status !== 'COMPLETE') {
				console.warn('[eSewa verify] status not COMPLETE:', callback.status);
				return res
					.status(400)
					.json({ success: false, message: `Payment not complete (status: ${callback.status})` });
			}

			if (!esewa.verifyCallbackSignature(callback)) {
				console.warn(
					'[eSewa verify] signature mismatch. received:',
					callback.signature
				);
				return res
					.status(400)
					.json({ success: false, message: 'Payment signature verification failed' });
			}

			const booking = await bookingService.getBookingByTransactionUuid(
				callback.transaction_uuid
			);
			if (!booking) {
				console.warn('[eSewa verify] no booking for uuid:', callback.transaction_uuid);
				return res.status(404).json({ success: false, message: 'Booking not found' });
			}

			if (booking.userId.toString() !== req.user!.userId) {
				console.warn(
					'[eSewa verify] owner mismatch. booking user:',
					booking.userId.toString(),
					'request user:',
					req.user!.userId
				);
				return res.status(403).json({ success: false, message: 'Forbidden' });
			}

			// Guard against tampered amounts (eSewa may return "1,000.0").
			const paidAmount = Number(callback.total_amount.replace(/,/g, ''));
			if (paidAmount !== booking.totalPrice) {
				console.warn(
					'[eSewa verify] amount mismatch. paid:',
					paidAmount,
					'expected:',
					booking.totalPrice
				);
				return res.status(400).json({ success: false, message: 'Payment amount mismatch' });
			}

			const updated = await bookingService.markBookingPayment(booking._id!.toString(), {
				status: 'CONFIRMED',
				paymentStatus: 'PAID',
				paymentRef: callback.transaction_code,
			});

			return res.status(200).json({
				success: true,
				message: 'Payment verified and booking confirmed',
				data: transformBooking(updated, req),
			});
		} catch (error: any) {
			return res.status(400).json({ success: false, message: error.message });
		}
	}
}
