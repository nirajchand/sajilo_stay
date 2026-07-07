import mongoose, { Schema } from 'mongoose';

export interface IRoom {
	_id: mongoose.Types.ObjectId;
	hotelId: mongoose.Types.ObjectId;
	type: string;
	capacity: number;
	pricePerNight: number;
	images: string[];
}

export type IRoomDocument = IRoom & mongoose.Document;

const RoomSchema = new Schema<IRoomDocument>(
	{
		hotelId: { type: Schema.Types.ObjectId, ref: 'Hotels', required: true },
		type: { type: String, required: true },
		capacity: { type: Number, required: true },
		pricePerNight: { type: Number, required: true },
		images: [{ type: String }],
	},
	{ timestamps: true }
);

export const RoomModel = mongoose.model<IRoomDocument>('Rooms', RoomSchema);
