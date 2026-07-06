import { HotelModel, type HotelDocument, type IHotel } from '../models/hotel.model.js';
import type { CreateHotelDto } from '../dtos/hotel.dto.js';

export type HotelFilters = {
	city?: string;
	roomType?: string;
	stars?: number;
	minPrice?: number;
	maxPrice?: number;
};

export async function createHotel(data: CreateHotelDto): Promise<HotelDocument> {
	const hotel = new HotelModel(data);
	return hotel.save();
}

export async function findAll(filters: HotelFilters): Promise<IHotel[]> {
	const query: Record<string, unknown> = {};

	if (filters.city) {
		query['location.address'] = { $regex: filters.city, $options: 'i' };
	}

	// roomType + price target the SAME room via $elemMatch, so a hotel only
	// matches when one of its rooms satisfies both the type and the price range.
	const roomMatch: Record<string, unknown> = {};
	if (filters.roomType) {
		roomMatch.roomType = { $regex: filters.roomType, $options: 'i' };
	}
	if (filters.minPrice !== undefined || filters.maxPrice !== undefined) {
		const priceQuery: Record<string, number> = {};
		if (filters.minPrice !== undefined) {
			priceQuery.$gte = filters.minPrice;
		}
		if (filters.maxPrice !== undefined) {
			priceQuery.$lte = filters.maxPrice;
		}
		roomMatch.pricePerNight = priceQuery;
	}
	if (Object.keys(roomMatch).length > 0) {
		query.rooms = { $elemMatch: roomMatch };
	}

	return HotelModel.find(query).lean<IHotel[]>().exec();
}

export async function findById(id: string): Promise<IHotel | null> {
	return HotelModel.findById(id).lean<IHotel>().exec();
}

export async function updateById(id: string, data: Partial<IHotel>): Promise<IHotel | null> {
	return HotelModel.findByIdAndUpdate(id, data, { new: true, runValidators: true })
		.lean<IHotel>()
		.exec();
}

export async function deleteById(id: string): Promise<void> {
	await HotelModel.findByIdAndDelete(id).exec();
}
