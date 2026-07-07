import mongoose, { Schema } from 'mongoose';

export type BookingStatus = 'PENDING' | 'CONFIRMED' | 'CANCELLED' | 'COMPLETED';

export type PaymentMethod = 'ESEWA' | 'PAY_AT_HOTEL';
export type PaymentStatus = 'PENDING' | 'PAID' | 'FAILED';

export interface IBooking {
	_id?: mongoose.Types.ObjectId;
	userId: mongoose.Types.ObjectId;
	roomId: mongoose.Types.ObjectId;
	hotelId: mongoose.Types.ObjectId;
	checkIn: Date;
	checkOut: Date;
	totalPrice: number;
	guests: number;
	status: BookingStatus;
	paymentMethod: PaymentMethod;
	paymentStatus: PaymentStatus;
	transactionUuid?: string;
	paymentRef?: string;
}

export type IBookingDocument = IBooking & mongoose.Document;

const BookingSchema = new Schema<IBookingDocument>(
	{
		userId: { type: Schema.Types.ObjectId, ref: 'Users', required: true },
		roomId: { type: Schema.Types.ObjectId, ref: 'Rooms', required: true },
		hotelId: { type: Schema.Types.ObjectId, ref: 'Hotels', required: true },
		checkIn: { type: Date, required: true },
		checkOut: { type: Date, required: true },
		totalPrice: { type: Number, required: true },
		guests: { type: Number, required: true, default: 1 },
		status: {
			type: String,
			enum: ['PENDING', 'CONFIRMED', 'CANCELLED', 'COMPLETED'],
			default: 'PENDING',
		},
		paymentMethod: {
			type: String,
			enum: ['ESEWA', 'PAY_AT_HOTEL'],
			default: 'PAY_AT_HOTEL',
		},
		paymentStatus: {
			type: String,
			enum: ['PENDING', 'PAID', 'FAILED'],
			default: 'PENDING',
		},
		transactionUuid: { type: String, index: true },
		paymentRef: { type: String },
	},
	{ timestamps: true }
);

export const BookingModel = mongoose.model<IBookingDocument>('Bookings', BookingSchema);
