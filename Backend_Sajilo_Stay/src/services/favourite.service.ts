import { findById as findHotelById } from '../repositories/hotel.repository.js';
import { getAverageRatingsByHotelIds } from '../repositories/review.repository.js';
import {
	addFavourite as addFavouriteInRepository,
	removeFavourite,
	findByUserId,
	exists,
} from '../repositories/favourite.repository.js';
import type { AddFavouriteDto } from '../dtos/favourite.dto.js';

export async function addFavourite(userId: string, data: AddFavouriteDto) {
	const hotel = await findHotelById(data.hotelId);
	if (!hotel) {
		throw new Error('Hotel not found');
	}

	const alreadyFavourited = await exists(userId, data.hotelId);
	if (alreadyFavourited) {
		throw new Error('Hotel is already in favourites');
	}

	return addFavouriteInRepository(userId, data.hotelId);
}

export async function removeFavouriteFromUser(userId: string, hotelId: string) {
	const removed = await removeFavourite(userId, hotelId);
	if (!removed) {
		throw new Error('Favourite not found');
	}
}

export async function getMyFavourites(userId: string) {
	const favourites = await findByUserId(userId);
	const hotelIds = favourites.map((favourite) => favourite.hotelId.toString());

	if (hotelIds.length === 0) {
		return [];
	}

	const hotels = await Promise.all(hotelIds.map((hotelId) => findHotelById(hotelId)));
	const ratings = await getAverageRatingsByHotelIds(hotelIds);

	return hotels
		.filter((hotel): hotel is NonNullable<typeof hotel> => hotel !== null)
		.map((hotel) => ({
			...hotel,
			avgRating: ratings.get(hotel._id.toString()) ?? null,
			isFavourite: true,
		}));
}
