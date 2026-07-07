import mongoose, { Schema } from 'mongoose';

export interface IReview {
	userId: mongoose.Types.ObjectId;
	hotelId: mongoose.Types.ObjectId;
	bookingId: mongoose.Types.ObjectId;
	rating: number;
	comment?: string;
}

export type IReviewDocument = IReview & mongoose.Document;

const ReviewSchema = new Schema<IReviewDocument>(
	{
		userId: { type: Schema.Types.ObjectId, ref: 'Users', required: true },
		hotelId: { type: Schema.Types.ObjectId, ref: 'Hotels', required: true },
		bookingId: { type: Schema.Types.ObjectId, ref: 'Bookings', required: true },
		rating: { type: Number, required: true, min: 1, max: 5 },
		comment: { type: String, trim: true, maxlength: 500 },
	},
	{ timestamps: true }
);

// One review per booking — a guest who books the same hotel again can review
// each completed stay separately.
ReviewSchema.index({ bookingId: 1 }, { unique: true });

export const ReviewModel = mongoose.model<IReviewDocument>('Reviews', ReviewSchema);
