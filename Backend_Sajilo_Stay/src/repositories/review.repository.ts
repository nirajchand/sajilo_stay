import mongoose from 'mongoose';
import { ReviewModel, type IReview } from '../models/review.model.js';
import type { CreateReviewDto, UpdateReviewDto } from '../dtos/review.dto.js';

export async function getAverageRatingsByHotelIds(
	hotelIds: string[]
): Promise<Map<string, number>> {
	if (hotelIds.length === 0) {
		return new Map();
	}

	const objectIds = hotelIds.map((id) => new mongoose.Types.ObjectId(id));
	const results = await ReviewModel.aggregate<{ _id: mongoose.Types.ObjectId; avgRating: number }>([
		{ $match: { hotelId: { $in: objectIds } } },
		{ $group: { _id: '$hotelId', avgRating: { $avg: '$rating' } } },
	]);

	const ratings = new Map<string, number>();
	for (const result of results) {
		ratings.set(result._id.toString(), Number(result.avgRating.toFixed(2)));
	}

	return ratings;
}

export async function findByUserIdAndHotelId(
	userId: string,
	hotelId: string
): Promise<IReview | null> {
	return ReviewModel.findOne({ userId, hotelId }).lean<IReview>().exec();
}

export async function findByBookingId(bookingId: string): Promise<IReview | null> {
	return ReviewModel.findOne({ bookingId }).lean<IReview>().exec();
}

export async function findByHotelId(hotelId: string): Promise<IReview[]> {
	return ReviewModel.find({ hotelId })
		.sort({ createdAt: -1 })
		.populate({ path: 'userId', select: 'fullName' })
		.lean<IReview[]>()
		.exec();
}

export async function findByUserId(userId: string): Promise<IReview[]> {
	return ReviewModel.find({ userId }).lean<IReview[]>().exec();
}

export async function findById(id: string): Promise<IReview | null> {
	return ReviewModel.findById(id).lean<IReview>().exec();
}

export async function createReview(
	userId: string,
	data: CreateReviewDto
): Promise<IReview> {
	const review = new ReviewModel({
		userId,
		...data,
	});
	const saved = await review.save();
	return saved.toObject() as IReview;
}

export async function updateById(id: string, data: UpdateReviewDto): Promise<IReview | null> {
	return ReviewModel.findByIdAndUpdate(id, data, { new: true, runValidators: true })
		.lean<IReview>()
		.exec();
}

export async function deleteById(id: string): Promise<void> {
	await ReviewModel.findByIdAndDelete(id).exec();
}

export async function deleteByHotelId(hotelId: string): Promise<void> {
	await ReviewModel.deleteMany({ hotelId }).exec();
}
