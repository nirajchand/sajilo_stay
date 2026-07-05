import { Request, Response } from 'express';
import mongoose from 'mongoose';
import * as roomService from '../services/room.service.js';
import {
	availabilityQueryDto,
	createRoomDto,
	updateRoomDto,
	type CreateRoomDto,
	type UpdateRoomDto,
} from '../dtos/room.dto.js';

function getRouteParam(value: string | string[]): string {
	return Array.isArray(value) ? value[0] : value;
}

function isValidObjectId(id: string): boolean {
	return mongoose.Types.ObjectId.isValid(id);
}

export class RoomController {
	async createRoom(req: Request, res: Response) {
		try {
			const hotelId = getRouteParam(req.params.hotelId);

			if (!isValidObjectId(hotelId)) {
				return res.status(400).json({
					success: false,
					message: 'Invalid hotel id',
				});
			}

			const parseData = createRoomDto.safeParse(req.body);
			if (!parseData.success) {
				return res.status(400).json({
					success: false,
					message: parseData.error.format(),
				});
			}

			const roomData: CreateRoomDto = parseData.data;
			const newRoom = await roomService.createRoom(hotelId, roomData);

			return res.status(201).json({
				success: true,
				message: 'Room created successfully',
				data: newRoom,
			});
		} catch (error: any) {
			const statusCode = error.message === 'Hotel not found' ? 404 : 400;
			return res.status(statusCode).json({ success: false, message: error.message });
		}
	}

	async getRoomsByHotel(req: Request, res: Response) {
		try {
			const hotelId = getRouteParam(req.params.hotelId);

			if (!isValidObjectId(hotelId)) {
				return res.status(400).json({
					success: false,
					message: 'Invalid hotel id',
				});
			}

			const rooms = await roomService.getRoomsByHotel(hotelId);

			return res.status(200).json({
				success: true,
				message: 'Rooms fetched successfully',
				data: rooms,
			});
		} catch (error: any) {
			const statusCode = error.message === 'Hotel not found' ? 404 : 400;
			return res.status(statusCode).json({ success: false, message: error.message });
		}
	}

	async getRoomById(req: Request, res: Response) {
		try {
			const id = getRouteParam(req.params.id);

			if (!isValidObjectId(id)) {
				return res.status(400).json({
					success: false,
					message: 'Invalid room id',
				});
			}

			const room = await roomService.getRoomById(id);
			if (!room) {
				return res.status(404).json({
					success: false,
					message: 'Room not found',
				});
			}

			return res.status(200).json({
				success: true,
				message: 'Room fetched successfully',
				data: room,
			});
		} catch (error: any) {
			return res.status(400).json({ success: false, message: error.message });
		}
	}

	async updateRoom(req: Request, res: Response) {
		try {
			const id = getRouteParam(req.params.id);

			if (!isValidObjectId(id)) {
				return res.status(400).json({
					success: false,
					message: 'Invalid room id',
				});
			}

			const parseData = updateRoomDto.safeParse(req.body);
			if (!parseData.success) {
				return res.status(400).json({
					success: false,
					message: parseData.error.format(),
				});
			}

			const roomData: UpdateRoomDto = parseData.data;
			const updatedRoom = await roomService.updateRoom(id, roomData);

			if (!updatedRoom) {
				return res.status(404).json({
					success: false,
					message: 'Room not found',
				});
			}

			return res.status(200).json({
				success: true,
				message: 'Room updated successfully',
				data: updatedRoom,
			});
		} catch (error: any) {
			return res.status(400).json({ success: false, message: error.message });
		}
	}

	async deleteRoom(req: Request, res: Response) {
		try {
			const id = getRouteParam(req.params.id);

			if (!isValidObjectId(id)) {
				return res.status(400).json({
					success: false,
					message: 'Invalid room id',
				});
			}

			const existingRoom = await roomService.getRoomById(id);
			if (!existingRoom) {
				return res.status(404).json({
					success: false,
					message: 'Room not found',
				});
			}

			await roomService.deleteRoom(id);

			return res.status(200).json({
				success: true,
				message: 'Room deleted successfully',
			});
		} catch (error: any) {
			return res.status(400).json({ success: false, message: error.message });
		}
	}

	async checkAvailability(req: Request, res: Response) {
		try {
			const id = getRouteParam(req.params.id);

			if (!isValidObjectId(id)) {
				return res.status(400).json({
					success: false,
					message: 'Invalid room id',
				});
			}

			const parseData = availabilityQueryDto.safeParse(req.query);
			if (!parseData.success) {
				return res.status(400).json({
					success: false,
					message: parseData.error.format(),
				});
			}

			const { checkIn, checkOut } = parseData.data;
			const result = await roomService.checkAvailability(id, checkIn, checkOut);

			return res.status(200).json({
				success: true,
				message: 'Availability checked successfully',
				data: result,
			});
		} catch (error: any) {
			const statusCode = error.message === 'Room not found' ? 404 : 400;
			return res.status(statusCode).json({ success: false, message: error.message });
		}
	}
}
