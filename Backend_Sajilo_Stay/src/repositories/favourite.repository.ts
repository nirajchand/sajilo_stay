import { FavouriteModel, type IFavourite } from '../models/favourite.model.js';

export async function addFavourite(userId: string, hotelId: string): Promise<IFavourite> {
	const favourite = new FavouriteModel({ userId, hotelId });
	const saved = await favourite.save();
	return saved.toObject() as IFavourite;
}

export async function removeFavourite(userId: string, hotelId: string): Promise<boolean> {
	const result = await FavouriteModel.findOneAndDelete({ userId, hotelId }).exec();
	return result !== null;
}

export async function findByUserId(userId: string): Promise<IFavourite[]> {
	return FavouriteModel.find({ userId }).sort({ createdAt: -1 }).lean<IFavourite[]>().exec();
}

export async function findHotelIdsByUserId(userId: string): Promise<string[]> {
	const favourites = await FavouriteModel.find({ userId }).select('hotelId').lean<{ hotelId: IFavourite['hotelId'] }[]>().exec();
	return favourites.map((favourite) => favourite.hotelId.toString());
}

export async function exists(userId: string, hotelId: string): Promise<boolean> {
	const favourite = await FavouriteModel.findOne({ userId, hotelId }).select('_id').lean().exec();
	return favourite !== null;
}

export async function deleteByHotelId(hotelId: string): Promise<void> {
	await FavouriteModel.deleteMany({ hotelId }).exec();
}
