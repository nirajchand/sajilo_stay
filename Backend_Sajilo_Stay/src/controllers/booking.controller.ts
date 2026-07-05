import { Request, Response } from 'express';
import mongoose from 'mongoose';
import * as bookingService from '../services/booking.service.js';
import {
	createBookingDto,
	updateBookingStatusDto,
	type CreateBookingDto,
	type UpdateBookingStatusDto,
} from '../dtos/booking.dto.js';
import { transformBooking } from '../utils/image.util.js';

function getRouteParam(value: string | string[]): string {
	return Array.isArray(value) ? value[0] : value;
}

function isValidObjectId(id: string): boolean {
	return mongoose.Types.ObjectId.isValid(id);
}

function mapServiceError(error: Error): number {
	switch (error.message) {
		case 'Room not found':
		case 'Booking not found':
			return 404;
		case 'Forbidden':
			return 403;
		case 'Booking cannot be cancelled':
		case 'Room is not available for the selected dates':
		case 'checkIn cannot be in the past':
			return 400;
		default:
			if (error.message.startsWith('Room capacity is')) {
				return 400;
			}
			return 400;
	}
}

export class BookingController {
	async createBooking(req: Request, res: Response) {
		try {
			const parseData = createBookingDto.safeParse(req.body);
			if (!parseData.success) {
				return res.status(400).json({
					success: false,
					message: parseData.error.format(),
				});
			}

			const bookingData: CreateBookingDto = parseData.data;
			const newBooking = await bookingService.createBooking(req.user!.userId, bookingData);

			return res.status(201).json({
				success: true,
				message: 'Booking created successfully',
				data: transformBooking(newBooking, req),
			});
		} catch (error: any) {
			return res.status(mapServiceError(error)).json({ success: false, message: error.message });
		}
	}

	async getMyBookings(req: Request, res: Response) {
		try {
			const bookings = await bookingService.getMyBookings(req.user!.userId);

			return res.status(200).json({
				success: true,
				message: 'Bookings fetched successfully',
				data: bookings.map((b) => transformBooking(b, req)),
			});
		} catch (error: any) {
			return res.status(400).json({ success: false, message: error.message });
		}
	}

	async getAllBookings(req: Request, res: Response) {
		try {
			const bookings = await bookingService.getAllBookings();

			return res.status(200).json({
				success: true,
				message: 'All bookings fetched successfully',
				data: bookings.map((b) => transformBooking(b, req)),
			});
		} catch (error: any) {
			return res.status(400).json({ success: false, message: error.message });
		}
	}

	async getBookingById(req: Request, res: Response) {
		try {
			const id = getRouteParam(req.params.id);

			if (!isValidObjectId(id)) {
				return res.status(400).json({
					success: false,
					message: 'Invalid booking id',
				});
			}

			const booking = await bookingService.getBookingById(id);
			if (!booking) {
				return res.status(404).json({
					success: false,
					message: 'Booking not found',
				});
			}

			const isOwner = booking.userId.toString() === req.user!.userId;
			const isAdmin = req.user!.role === 'ADMIN';
			if (!isOwner && !isAdmin) {
				return res.status(403).json({
					success: false,
					message: 'Forbidden',
				});
			}

			return res.status(200).json({
				success: true,
				message: 'Booking fetched successfully',
				data: transformBooking(booking, req),
			});
		} catch (error: any) {
			return res.status(400).json({ success: false, message: error.message });
		}
	}

	async cancelBooking(req: Request, res: Response) {
		try {
			const id = getRouteParam(req.params.id);

			if (!isValidObjectId(id)) {
				return res.status(400).json({
					success: false,
					message: 'Invalid booking id',
				});
			}

			const cancelledBooking = await bookingService.cancelBooking(id, req.user!.userId);

			return res.status(200).json({
				success: true,
				message: 'Booking cancelled successfully',
				data: transformBooking(cancelledBooking, req),
			});
		} catch (error: any) {
			return res.status(mapServiceError(error)).json({ success: false, message: error.message });
		}
	}

	async updateBookingStatus(req: Request, res: Response) {
		try {
			const id = getRouteParam(req.params.id);

			if (!isValidObjectId(id)) {
				return res.status(400).json({
					success: false,
					message: 'Invalid booking id',
				});
			}

			const parseData = updateBookingStatusDto.safeParse(req.body);
			if (!parseData.success) {
				return res.status(400).json({
					success: false,
					message: parseData.error.format(),
				});
			}

			const statusData: UpdateBookingStatusDto = parseData.data;
			const updatedBooking = await bookingService.updateBookingStatus(id, statusData.status);

			return res.status(200).json({
				success: true,
				message: 'Booking status updated successfully',
				data: updatedBooking,
			});
		} catch (error: any) {
			return res.status(mapServiceError(error)).json({ success: false, message: error.message });
		}
	}
}
