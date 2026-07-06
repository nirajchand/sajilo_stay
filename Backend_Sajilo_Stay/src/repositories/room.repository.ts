import { RoomModel, type IRoom, type IRoomDocument } from '../models/room.model.js';
import type { CreateRoomDto } from '../dtos/room.dto.js';
import type { HotelRoomType } from '../types/hotel.types.js';

export async function createRoom(hotelId: string, data: CreateRoomDto): Promise<IRoomDocument> {
	const room = new RoomModel({
		hotelId,
		...data,
		images: data.images ?? [],
	});
	return room.save();
}

export async function findByHotelId(hotelId: string): Promise<IRoom[]> {
	return RoomModel.find({ hotelId }).lean<IRoom[]>().exec();
}

export async function findById(id: string): Promise<IRoom | null> {
	return RoomModel.findById(id).lean<IRoom>().exec();
}

export async function updateById(id: string, data: Partial<IRoom>): Promise<IRoom | null> {
	return RoomModel.findByIdAndUpdate(id, data, { new: true, runValidators: true })
		.lean<IRoom>()
		.exec();
}

export async function deleteById(id: string): Promise<void> {
	await RoomModel.findByIdAndDelete(id).exec();
}

export async function createRoomsFromHotelEmbedded(
	hotelId: string,
	rooms: HotelRoomType[]
): Promise<void> {
	const roomDocuments = rooms.map((room) => ({
		hotelId,
		type: room.roomType,
		capacity: room.capacity,
		pricePerNight: room.pricePerNight,
		images: room.roomImage ? [room.roomImage] : [],
	}));

	await RoomModel.insertMany(roomDocuments);
}

export async function deleteByHotelId(hotelId: string): Promise<void> {
	await RoomModel.deleteMany({ hotelId }).exec();
}
