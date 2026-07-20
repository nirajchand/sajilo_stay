import { findById as findRoomById } from '../repositories/room.repository.js';
import { findByUserId as findReviewsByUserId } from '../repositories/review.repository.js';
import {
	createBooking as createBookingInRepository,
	findById,
	findByIdPopulated,
	findByTransactionUuid,
	findByUserId,
	findAll,
	updateStatusById,
	markPaymentById,
	hasOverlappingConfirmedBooking,
} from '../repositories/booking.repository.js';
import type { CreateBookingDto } from '../dtos/booking.dto.js';
import type { BookingStatus, PaymentStatus } from '../models/booking.model.js';

const MS_PER_NIGHT = 1000 * 60 * 60 * 24;

function calculateNights(checkIn: Date, checkOut: Date): number {
	const nights = Math.ceil((checkOut.getTime() - checkIn.getTime()) / MS_PER_NIGHT);
	return nights > 0 ? nights : 1;
}

function generateTransactionUuid(): string {
	return `SJST-${Date.now()}-${Math.floor(Math.random() * 1_000_000)}`;
}

export async function createBooking(userId: string, data: CreateBookingDto) {
	const room = await findRoomById(data.roomId);
	if (!room) {
		throw new Error('Room not found');
	}

	if (data.guests > room.capacity) {
		throw new Error(`Room capacity is ${room.capacity} guests`);
	}

	const checkIn = new Date(data.checkIn);
	const checkOut = new Date(data.checkOut);

	if (checkIn < new Date()) {
		throw new Error('checkIn cannot be in the past');
	}

	const hasOverlap = await hasOverlappingConfirmedBooking(data.roomId, checkIn, checkOut);
	if (hasOverlap) {
		throw new Error('Room is not available for the selected dates');
	}

	const nights = calculateNights(checkIn, checkOut);
	const totalPrice = room.pricePerNight * nights;
	const hotelId = room.hotelId.toString();

	// Pay-at-hotel is confirmed immediately; eSewa stays PENDING until the
	// gateway callback is verified by the payment service.
	const isEsewa = data.paymentMethod === 'ESEWA';

	return createBookingInRepository({
		userId,
		roomId: data.roomId,
		hotelId,
		checkIn,
		checkOut,
		totalPrice,
		guests: data.guests,
		status: isEsewa ? 'PENDING' : 'CONFIRMED',
		paymentMethod: data.paymentMethod,
		paymentStatus: 'PENDING',
		transactionUuid: isEsewa ? generateTransactionUuid() : undefined,
	});
}

export async function getMyBookings(userId: string) {
	const bookings = await findByUserId(userId);
	const reviews = await findReviewsByUserId(userId);

	// Reviews are unique per booking; key by booking so each booking knows
	// whether it specifically has been reviewed and with what rating.
	const reviewByBooking = new Map<string, { rating: number }>();
	for (const review of reviews) {
		if (review.bookingId) {
			reviewByBooking.set(review.bookingId.toString(), { rating: review.rating });
		}
	}

	return bookings.map((booking: any) => {
		const bookingId = booking._id?.toString();
		const review = bookingId ? reviewByBooking.get(bookingId) : undefined;
		return {
			...booking,
			isReviewed: Boolean(review),
			userRating: review?.rating ?? null,
		};
	});
}

export async function getAllBookings() {
	return findAll();
}

export async function getBookingById(id: string) {
	return findByIdPopulated(id);
}

export async function getBookingByIdRaw(id: string) {
	return findById(id);
}

export async function getBookingByTransactionUuid(transactionUuid: string) {
	return findByTransactionUuid(transactionUuid);
}

export async function markBookingPayment(
	id: string,
	data: { status: BookingStatus; paymentStatus: PaymentStatus; paymentRef?: string }
) {
	const updated = await markPaymentById(id, data);
	if (!updated) {
		throw new Error('Booking not found');
	}
	return updated;
}

export async function cancelBooking(id: string, userId: string) {
	const booking = await findById(id);
	if (!booking) {
		throw new Error('Booking not found');
	}

	if (booking.userId.toString() !== userId) {
		throw new Error('Forbidden');
	}

	if (booking.status === 'CANCELLED' || booking.status === 'COMPLETED') {
		throw new Error('Booking cannot be cancelled');
	}

	const updatedBooking = await updateStatusById(id, 'CANCELLED');
	if (!updatedBooking) {
		throw new Error('Booking not found');
	}

	return updatedBooking;
}

export async function updateBookingStatus(id: string, status: BookingStatus) {
	const booking = await findById(id);
	if (!booking) {
		throw new Error('Booking not found');
	}

	const updatedBooking = await updateStatusById(id, status);
	if (!updatedBooking) {
		throw new Error('Booking not found');
	}

	return updatedBooking;
}
