import mongoose, { Schema } from 'mongoose';
import type { HotelLocationType, HotelRoomType, HotelType } from '../types/hotel.types.js';

export interface IHotel extends HotelType {
  _id: mongoose.Types.ObjectId;
  location: HotelLocationType;
  rooms: HotelRoomType[];
}

export type HotelDocument = IHotel & mongoose.Document;

const HotelRoomSchema = new Schema<HotelRoomType>(
  {
    roomType: { type: String, required: true },
    pricePerNight: { type: Number, required: true },
    capacity: { type: Number, required: true },
    roomImage: { type: String, default: '' },
  },
  { _id: false }
);

const HotelLocationSchema = new Schema<HotelLocationType>(
  {
    address: { type: String, required: true },
    coordinates: {
      type: [Number],
      required: true,
      validate: {
        validator: (value: number[]) => Array.isArray(value) && value.length === 2,
        message: 'Coordinates must contain exactly Latitude and Longitude',
      },
    },
  },
  { _id: false }
);

const HotelSchema = new Schema<HotelDocument>(
  {
    hotelName: { type: String, required: true, trim: true },
    description: { type: String, required: true },
    location: { type: HotelLocationSchema, required: true },
    gallery: { type: [String], required: true, default: [] },
    rooms: { type: [HotelRoomSchema], required: true, default: [] },
  },
  { timestamps: true }
);

export const HotelModel = mongoose.model<HotelDocument>('Hotels', HotelSchema);