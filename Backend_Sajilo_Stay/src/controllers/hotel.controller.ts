import { Request, Response } from 'express';
import mongoose from 'mongoose';
import * as hotelService from '../services/hotel.service.js';
import {
	createHotelDto,
	hotelFiltersDto,
	updateHotelDto,
	type CreateHotelDto,
	type UpdateHotelDto,
} from '../dtos/hotel.dto.js';

type UploadedFiles = {
	gallery?: Express.Multer.File[];
	roomImages?: Express.Multer.File[];
};

function parseJsonBody<T>(value: unknown, fallback: T): T {
	if (typeof value !== 'string') {
		return (value ?? fallback) as T;
	}

	try {
		return JSON.parse(value) as T;
	} catch {
		return fallback;
	}
}

function buildFileUrl(_req: Request, fileName: string): string {
	return fileName;
}

function toImageUrl(req: Request, path: string): string {
	if (!path) return '';
	if (path.startsWith('http')) return path;
	return `${req.protocol}://${req.get('host')}/uploads/hotels/${path}`;
}

function transformHotel(hotel: any, req: Request): any {
	return {
		...hotel,
		gallery: (hotel.gallery ?? []).map((img: string) => toImageUrl(req, img)),
		rooms: (hotel.rooms ?? []).map((room: any) => ({
			...room,
			roomImage: room.roomImage ? toImageUrl(req, room.roomImage) : undefined,
		})),
		bookableRooms: (hotel.bookableRooms ?? []).map((room: any) => ({
			...room,
			images: (room.images ?? []).map((img: string) => toImageUrl(req, img)),
		})),
	};
}

function getRouteParam(value: string | string[]): string {
	return Array.isArray(value) ? value[0] : value;
}

function isValidObjectId(id: string): boolean {
	return mongoose.Types.ObjectId.isValid(id);
}

export class HotelController {
	async getHotels(req: Request, res: Response) {
		try {
			const parseData = hotelFiltersDto.safeParse(req.query);
			if (!parseData.success) {
				return res.status(400).json({
					success: false,
					message: parseData.error.format(),
				});
			}

			const hotels = await hotelService.getHotels(parseData.data, req.user?.userId);

			return res.status(200).json({
				success: true,
				message: 'Hotels fetched successfully',
				data: hotels.map((h) => transformHotel(h, req)),
			});
		} catch (error: any) {
			return res.status(400).json({ success: false, message: error.message });
		}
	}

	async getHotelById(req: Request, res: Response) {
		try {
			const id = getRouteParam(req.params.id);

			if (!isValidObjectId(id)) {
				return res.status(400).json({
					success: false,
					message: 'Invalid hotel id',
				});
			}

			const hotel = await hotelService.getHotelById(id, req.user?.userId);
			if (!hotel) {
				return res.status(404).json({
					success: false,
					message: 'Hotel not found',
				});
			}

			return res.status(200).json({
				success: true,
				message: 'Hotel fetched successfully',
				data: transformHotel(hotel, req),
			});
		} catch (error: any) {
			return res.status(400).json({ success: false, message: error.message });
		}
	}

	async createHotel(req: Request, res: Response) {
		try {
			const files = (req.files ?? {}) as UploadedFiles;
			const galleryFiles = files.gallery ?? [];
			const roomImageFiles = files.roomImages ?? [];

			if (galleryFiles.length < 1 || galleryFiles.length > 5) {
				return res.status(400).json({
					success: false,
					message: 'Gallery must contain at least 1 image and at most 5 images',
				});
			}

			const hotelRooms = parseJsonBody<Array<Record<string, unknown>>>(req.body.rooms, []);
			if (!Array.isArray(hotelRooms) || hotelRooms.length === 0) {
				return res.status(400).json({
					success: false,
					message: 'At least one room is required',
				});
			}

			if (roomImageFiles.length !== hotelRooms.length) {
				return res.status(400).json({
					success: false,
					message: 'Please upload exactly one image for each room',
				});
			}

			const normalizedRooms = hotelRooms.map((room, index) => ({
				...room,
				roomImage: buildFileUrl(req, roomImageFiles[index]?.filename ?? ''),
			}));

			const payload = {
				hotelName: req.body.hotelName,
				description: req.body.description,
				location: parseJsonBody(req.body.location, req.body.location),
				gallery: galleryFiles.map((file) => buildFileUrl(req, file.filename)),
				rooms: normalizedRooms,
			};

			const parseData = createHotelDto.safeParse(payload);
			if (!parseData.success) {
				return res.status(400).json({
					success: false,
					message: parseData.error.format(),
				});
			}

			const hotelData: CreateHotelDto = parseData.data;
			const newHotel = await hotelService.createHotel(hotelData);

			return res.status(201).json({
				success: true,
				message: 'Hotel created successfully',
				data: newHotel,
			});
		} catch (error: any) {
			return res.status(400).json({ success: false, message: error.message });
		}
	}

	async updateHotel(req: Request, res: Response) {
		try {
			const id = getRouteParam(req.params.id);

			if (!isValidObjectId(id)) {
				return res.status(400).json({
					success: false,
					message: 'Invalid hotel id',
				});
			}

			const parseData = updateHotelDto.safeParse(req.body);
			if (!parseData.success) {
				return res.status(400).json({
					success: false,
					message: parseData.error.format(),
				});
			}

			const hotelData: UpdateHotelDto = parseData.data;
			const updatedHotel = await hotelService.updateHotel(id, hotelData);

			if (!updatedHotel) {
				return res.status(404).json({
					success: false,
					message: 'Hotel not found',
				});
			}

			return res.status(200).json({
				success: true,
				message: 'Hotel updated successfully',
				data: updatedHotel,
			});
		} catch (error: any) {
			return res.status(400).json({ success: false, message: error.message });
		}
	}

	async deleteHotel(req: Request, res: Response) {
		try {
			const id = getRouteParam(req.params.id);

			if (!isValidObjectId(id)) {
				return res.status(400).json({
					success: false,
					message: 'Invalid hotel id',
				});
			}

			const existingHotel = await hotelService.getHotelById(id);
			if (!existingHotel) {
				return res.status(404).json({
					success: false,
					message: 'Hotel not found',
				});
			}

			await hotelService.deleteHotel(id);

			return res.status(200).json({
				success: true,
				message: 'Hotel deleted successfully',
			});
		} catch (error: any) {
			const statusCode = error.message === 'Cannot delete hotel with active bookings' ? 400 : 400;
			return res.status(statusCode).json({ success: false, message: error.message });
		}
	}
}
