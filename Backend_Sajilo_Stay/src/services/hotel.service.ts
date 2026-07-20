import {
	createHotel as createHotelInRepository,
	findAll,
	findById,
	updateById,
	deleteById,
	type HotelFilters,
} from '../repositories/hotel.repository.js';
import { getAverageRatingsByHotelIds } from '../repositories/review.repository.js';
import { deleteByHotelId as deleteReviewsByHotelId } from '../repositories/review.repository.js';
import { findHotelIdsByUserId } from '../repositories/favourite.repository.js';
import { deleteByHotelId as deleteFavouritesByHotelId } from '../repositories/favourite.repository.js';
import {
	createRoomsFromHotelEmbedded,
	findByHotelId as findRoomsByHotelId,
	deleteByHotelId as deleteRoomsByHotelId,
} from '../repositories/room.repository.js';
import { hasActiveBookingsForHotel } from '../repositories/booking.repository.js';
import type { CreateHotelDto } from '../dtos/hotel.dto.js';
import type { IHotel } from '../models/hotel.model.js';
import type { UpdateHotelDto } from '../dtos/hotel.dto.js';
import type { IRoom } from '../models/room.model.js';

type HotelWithRating = IHotel & {
	avgRating: number | null;
	isFavourite: boolean;
};

type HotelDetail = HotelWithRating & {
	bookableRooms: IRoom[];
};

async function attachAvgRating(hotel: IHotel, isFavourite: boolean): Promise<HotelWithRating> {
	const ratings = await getAverageRatingsByHotelIds([hotel._id.toString()]);
	return {
		...hotel,
		avgRating: ratings.get(hotel._id.toString()) ?? null,
		isFavourite,
	};
}

async function attachAvgRatings(
	hotels: IHotel[],
	favouriteHotelIds: Set<string>
): Promise<HotelWithRating[]> {
	const hotelIds = hotels.map((hotel) => hotel._id.toString());
	const ratings = await getAverageRatingsByHotelIds(hotelIds);

	return hotels.map((hotel) => ({
		...hotel,
		avgRating: ratings.get(hotel._id.toString()) ?? null,
		isFavourite: favouriteHotelIds.has(hotel._id.toString()),
	}));
}

function filterByStars(hotels: HotelWithRating[], stars?: number): HotelWithRating[] {
	if (stars === undefined) {
		return hotels;
	}

	return hotels.filter((hotel) => hotel.avgRating !== null && hotel.avgRating >= stars);
}

export async function createHotel(data: CreateHotelDto) {
	const hotel = await createHotelInRepository(data);
	await createRoomsFromHotelEmbedded(hotel._id.toString(), data.rooms);
	return hotel;
}

export async function getHotels(filters: HotelFilters, userId?: string) {
	const { stars, ...repositoryFilters } = filters;
	const hotels = await findAll(repositoryFilters);
	const favouriteHotelIds = new Set(userId ? await findHotelIdsByUserId(userId) : []);
	const hotelsWithRatings = await attachAvgRatings(hotels, favouriteHotelIds);
	return filterByStars(hotelsWithRatings, stars);
}

export async function getHotelById(id: string, userId?: string): Promise<HotelDetail | null> {
	const hotel = await findById(id);
	if (!hotel) {
		return null;
	}

	const isFavourite = userId ? (await findHotelIdsByUserId(userId)).includes(id) : false;
	const hotelWithRating = await attachAvgRating(hotel, isFavourite);
	const bookableRooms = await findRoomsByHotelId(id);

	return {
		...hotelWithRating,
		bookableRooms,
	};
}

export async function updateHotel(id: string, data: UpdateHotelDto) {
	return updateById(id, data);
}

export async function deleteHotel(id: string) {
	const hasActiveBookings = await hasActiveBookingsForHotel(id);
	if (hasActiveBookings) {
		throw new Error('Cannot delete hotel with active bookings');
	}

	await deleteRoomsByHotelId(id);
	await deleteFavouritesByHotelId(id);
	await deleteReviewsByHotelId(id);
	await deleteById(id);
}
