import { findById as findHotelById } from '../repositories/hotel.repository.js';
import { hasOverlappingConfirmedBooking } from '../repositories/booking.repository.js';
import {
	createRoom as createRoomInRepository,
	findByHotelId,
	findById,
	updateById,
	deleteById,
} from '../repositories/room.repository.js';
import type { CreateRoomDto, UpdateRoomDto } from '../dtos/room.dto.js';

export async function createRoom(hotelId: string, data: CreateRoomDto) {
	const hotel = await findHotelById(hotelId);
	if (!hotel) {
		throw new Error('Hotel not found');
	}

	return createRoomInRepository(hotelId, data);
}

export async function getRoomsByHotel(hotelId: string) {
	const hotel = await findHotelById(hotelId);
	if (!hotel) {
		throw new Error('Hotel not found');
	}

	return findByHotelId(hotelId);
}

export async function getRoomById(id: string) {
	return findById(id);
}

export async function updateRoom(id: string, data: UpdateRoomDto) {
	return updateById(id, data);
}

export async function deleteRoom(id: string) {
	await deleteById(id);
}

export async function checkAvailability(roomId: string, checkIn: Date, checkOut: Date) {
	const room = await findById(roomId);
	if (!room) {
		throw new Error('Room not found');
	}

	const hasOverlap = await hasOverlappingConfirmedBooking(roomId, checkIn, checkOut);

	return { available: !hasOverlap };
}
