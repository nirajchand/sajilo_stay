import {
	BookingModel,
	type BookingStatus,
	type IBooking,
	type PaymentMethod,
	type PaymentStatus,
} from '../models/booking.model.js';

// Populate hotel + room so list/detail responses carry display data.
const POPULATE = [
	{ path: 'hotelId', select: 'hotelName description location gallery' },
	{ path: 'roomId', select: 'type capacity pricePerNight images' },
];

export async function hasOverlappingConfirmedBooking(
	roomId: string,
	checkIn: Date,
	checkOut: Date
): Promise<boolean> {
	const overlappingBooking = await BookingModel.findOne({
		roomId,
		status: 'CONFIRMED',
		checkIn: { $lt: checkOut },
		checkOut: { $gt: checkIn },
	}).exec();

	return overlappingBooking !== null;
}

export async function createBooking(data: {
	userId: string;
	roomId: string;
	hotelId: string;
	checkIn: Date;
	checkOut: Date;
	totalPrice: number;
	guests: number;
	status: BookingStatus;
	paymentMethod: PaymentMethod;
	paymentStatus: PaymentStatus;
	transactionUuid?: string;
}): Promise<IBooking> {
	const booking = new BookingModel(data);
	const saved = await booking.save();
	return saved.toObject() as IBooking;
}

export async function findById(id: string): Promise<IBooking | null> {
	return BookingModel.findById(id).lean<IBooking>().exec();
}

export async function findByIdPopulated(id: string): Promise<IBooking | null> {
	return BookingModel.findById(id).populate(POPULATE).lean<IBooking>().exec();
}

export async function findByTransactionUuid(transactionUuid: string): Promise<IBooking | null> {
	return BookingModel.findOne({ transactionUuid }).lean<IBooking>().exec();
}

export async function findByUserId(userId: string): Promise<IBooking[]> {
	return BookingModel.find({ userId })
		.sort({ createdAt: -1 })
		.populate(POPULATE)
		.lean<IBooking[]>()
		.exec();
}

export async function findAll(): Promise<IBooking[]> {
	return BookingModel.find().sort({ createdAt: -1 }).populate(POPULATE).lean<IBooking[]>().exec();
}

export async function updateStatusById(
	id: string,
	status: BookingStatus
): Promise<IBooking | null> {
	return BookingModel.findByIdAndUpdate(id, { status }, { new: true, runValidators: true })
		.populate(POPULATE)
		.lean<IBooking>()
		.exec();
}

export async function markPaymentById(
	id: string,
	data: { status: BookingStatus; paymentStatus: PaymentStatus; paymentRef?: string }
): Promise<IBooking | null> {
	return BookingModel.findByIdAndUpdate(id, data, { new: true, runValidators: true })
		.populate(POPULATE)
		.lean<IBooking>()
		.exec();
}

export async function findReviewEligibleBooking(
	userId: string,
	hotelId: string,
	bookingId: string
): Promise<IBooking | null> {
	// A stay counts as "completed" — and therefore reviewable — once its
	// checkout date has passed, for any booking the user didn't cancel. This
	// matches what the app shows under the "Completed" tab.
	return BookingModel.findOne({
		_id: bookingId,
		userId,
		hotelId,
		status: { $ne: 'CANCELLED' },
		checkOut: { $lte: new Date() },
	})
		.lean<IBooking>()
		.exec();
}

export async function hasActiveBookingsForHotel(hotelId: string): Promise<boolean> {
	const activeBooking = await BookingModel.findOne({
		hotelId,
		status: { $in: ['PENDING', 'CONFIRMED'] },
	})
		.select('_id')
		.lean()
		.exec();

	return activeBooking !== null;
}
