import { Request, Response } from 'express';
import mongoose from 'mongoose';
import * as reviewService from '../services/review.service.js';
import {
	createReviewDto,
	updateReviewDto,
	type CreateReviewDto,
	type UpdateReviewDto,
} from '../dtos/review.dto.js';

function getRouteParam(value: string | string[]): string {
	return Array.isArray(value) ? value[0] : value;
}

function isValidObjectId(id: string): boolean {
	return mongoose.Types.ObjectId.isValid(id);
}

function mapServiceError(error: Error): number {
	switch (error.message) {
		case 'Review not found':
			return 404;
		case 'Forbidden':
			return 403;
		case 'You have already reviewed this booking':
			return 409;
		case 'You must complete a stay before leaving a review':
			return 400;
		default:
			return 400;
	}
}

export class ReviewController {
	async createReview(req: Request, res: Response) {
		try {
			const parseData = createReviewDto.safeParse(req.body);
			if (!parseData.success) {
				return res.status(400).json({
					success: false,
					message: parseData.error.format(),
				});
			}

			const reviewData: CreateReviewDto = parseData.data;
			const newReview = await reviewService.createReview(req.user!.userId, reviewData);

			return res.status(201).json({
				success: true,
				message: 'Review created successfully',
				data: newReview,
			});
		} catch (error: any) {
			return res.status(mapServiceError(error)).json({ success: false, message: error.message });
		}
	}

	async getHotelReviews(req: Request, res: Response) {
		try {
			const hotelId = getRouteParam(req.params.id);

			if (!isValidObjectId(hotelId)) {
				return res.status(400).json({
					success: false,
					message: 'Invalid hotel id',
				});
			}

			const reviews = await reviewService.getHotelReviews(hotelId);

			// Flatten the populated user so the client gets a ready-to-render shape.
			const data = reviews.map((review: any) => ({
				_id: review._id,
				rating: review.rating,
				comment: review.comment ?? '',
				createdAt: review.createdAt,
				reviewerName:
					review.userId && typeof review.userId === 'object'
						? review.userId.fullName
						: 'Guest',
			}));

			return res.status(200).json({
				success: true,
				message: 'Hotel reviews fetched successfully',
				data,
			});
		} catch (error: any) {
			return res.status(400).json({ success: false, message: error.message });
		}
	}

	async updateReview(req: Request, res: Response) {
		try {
			const id = getRouteParam(req.params.id);

			if (!isValidObjectId(id)) {
				return res.status(400).json({
					success: false,
					message: 'Invalid review id',
				});
			}

			const parseData = updateReviewDto.safeParse(req.body);
			if (!parseData.success) {
				return res.status(400).json({
					success: false,
					message: parseData.error.format(),
				});
			}

			const reviewData: UpdateReviewDto = parseData.data;
			const updatedReview = await reviewService.updateReview(id, req.user!.userId, reviewData);

			return res.status(200).json({
				success: true,
				message: 'Review updated successfully',
				data: updatedReview,
			});
		} catch (error: any) {
			return res.status(mapServiceError(error)).json({ success: false, message: error.message });
		}
	}

	async deleteReview(req: Request, res: Response) {
		try {
			const id = getRouteParam(req.params.id);

			if (!isValidObjectId(id)) {
				return res.status(400).json({
					success: false,
					message: 'Invalid review id',
				});
			}

			await reviewService.deleteReview(id, req.user!.userId);

			return res.status(200).json({
				success: true,
				message: 'Review deleted successfully',
			});
		} catch (error: any) {
			return res.status(mapServiceError(error)).json({ success: false, message: error.message });
		}
	}

	async deleteAnyReview(req: Request, res: Response) {
		try {
			const id = getRouteParam(req.params.id);

			if (!isValidObjectId(id)) {
				return res.status(400).json({
					success: false,
					message: 'Invalid review id',
				});
			}

			await reviewService.deleteAnyReview(id);

			return res.status(200).json({
				success: true,
				message: 'Review deleted successfully',
			});
		} catch (error: any) {
			return res.status(mapServiceError(error)).json({ success: false, message: error.message });
		}
	}
}
