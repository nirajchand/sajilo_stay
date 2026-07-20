import { findReviewEligibleBooking } from '../repositories/booking.repository.js';
import {
	createReview as createReviewInRepository,
	findByBookingId,
	findByHotelId,
	findById,
	updateById,
	deleteById,
} from '../repositories/review.repository.js';
import type { CreateReviewDto, UpdateReviewDto } from '../dtos/review.dto.js';

export async function createReview(userId: string, data: CreateReviewDto) {
	const eligibleBooking = await findReviewEligibleBooking(userId, data.hotelId, data.bookingId);
	if (!eligibleBooking) {
		throw new Error('You must complete a stay before leaving a review');
	}

	const existingReview = await findByBookingId(data.bookingId);
	if (existingReview) {
		throw new Error('You have already reviewed this booking');
	}

	return createReviewInRepository(userId, data);
}

export async function getHotelReviews(hotelId: string) {
	return findByHotelId(hotelId);
}

export async function updateReview(id: string, userId: string, data: UpdateReviewDto) {
	const review = await findById(id);
	if (!review) {
		throw new Error('Review not found');
	}

	if (review.userId.toString() !== userId) {
		throw new Error('Forbidden');
	}

	const updatedReview = await updateById(id, data);
	if (!updatedReview) {
		throw new Error('Review not found');
	}

	return updatedReview;
}

export async function deleteReview(id: string, userId: string) {
	const review = await findById(id);
	if (!review) {
		throw new Error('Review not found');
	}

	if (review.userId.toString() !== userId) {
		throw new Error('Forbidden');
	}

	await deleteById(id);
}

export async function deleteAnyReview(id: string) {
	const review = await findById(id);
	if (!review) {
		throw new Error('Review not found');
	}

	await deleteById(id);
}
