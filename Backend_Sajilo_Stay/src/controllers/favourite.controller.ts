import { Request, Response } from 'express';
import mongoose from 'mongoose';
import * as favouriteService from '../services/favourite.service.js';
import { addFavouriteDto, type AddFavouriteDto } from '../dtos/favourite.dto.js';

function getRouteParam(value: string | string[]): string {
	return Array.isArray(value) ? value[0] : value;
}

function isValidObjectId(id: string): boolean {
	return mongoose.Types.ObjectId.isValid(id);
}

function mapServiceError(error: Error): number {
	switch (error.message) {
		case 'Hotel not found':
		case 'Favourite not found':
			return 404;
		case 'Hotel is already in favourites':
			return 409;
		default:
			return 400;
	}
}

export class FavouriteController {
	async addFavourite(req: Request, res: Response) {
		try {
			const parseData = addFavouriteDto.safeParse(req.body);
			if (!parseData.success) {
				return res.status(400).json({
					success: false,
					message: parseData.error.format(),
				});
			}

			const favouriteData: AddFavouriteDto = parseData.data;
			const favourite = await favouriteService.addFavourite(req.user!.userId, favouriteData);

			return res.status(201).json({
				success: true,
				message: 'Hotel added to favourites',
				data: favourite,
			});
		} catch (error: any) {
			return res.status(mapServiceError(error)).json({ success: false, message: error.message });
		}
	}

	async removeFavourite(req: Request, res: Response) {
		try {
			const hotelId = getRouteParam(req.params.hotelId);

			if (!isValidObjectId(hotelId)) {
				return res.status(400).json({
					success: false,
					message: 'Invalid hotel id',
				});
			}

			await favouriteService.removeFavouriteFromUser(req.user!.userId, hotelId);

			return res.status(200).json({
				success: true,
				message: 'Hotel removed from favourites',
			});
		} catch (error: any) {
			return res.status(mapServiceError(error)).json({ success: false, message: error.message });
		}
	}

	async getMyFavourites(req: Request, res: Response) {
		try {
			const favourites = await favouriteService.getMyFavourites(req.user!.userId);

			return res.status(200).json({
				success: true,
				message: 'Favourites fetched successfully',
				data: favourites,
			});
		} catch (error: any) {
			return res.status(400).json({ success: false, message: error.message });
		}
	}
}
