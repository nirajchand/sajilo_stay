import z from 'zod';

export const hotelLocationSchema = z.object({
  address: z.string().min(1, 'Address is required'),
  coordinates: z.array(z.number()).length(2, 'Coordinates must contain exactly Latitude and Longitude'),
});

export const hotelRoomSchema = z.object({
  roomType: z.string().min(1, 'Room type name is required'),
  pricePerNight: z.number().positive('Price must be a positive number'),
  capacity: z.number().int().positive('Capacity must be a positive whole number'),
  roomImage: z.string().min(1).optional(),
});

export const hotelSubmitSchema = z.object({
  hotelName: z.string().min(3, 'Hotel name must be at least 3 characters long'),
  description: z.string().min(10, 'Provide a longer description'),
  location: hotelLocationSchema,
  gallery: z.array(z.string().min(1)),
  rooms: z.array(hotelRoomSchema).min(1, 'You must add at least one room type'),
});

export type HotelLocationType = z.infer<typeof hotelLocationSchema>;
export type HotelRoomType = z.infer<typeof hotelRoomSchema>;
export type HotelType = z.infer<typeof hotelSubmitSchema>;