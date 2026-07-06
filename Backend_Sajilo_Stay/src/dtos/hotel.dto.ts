import { z } from 'zod';
import { hotelSubmitSchema } from '../types/hotel.types.js';

export const createHotelDto = hotelSubmitSchema.pick({
	hotelName: true,
	description: true,
	location: true,
	gallery: true,
	rooms: true,
});

export type CreateHotelDto = z.infer<typeof createHotelDto>;

export const updateHotelDto = createHotelDto.partial();
export type UpdateHotelDto = z.infer<typeof updateHotelDto>;

export const hotelFiltersDto = z.object({
	city: z.string().optional(),
	roomType: z.string().optional(),
	stars: z.coerce.number().int().min(1).max(5).optional(),
	minPrice: z.coerce.number().positive().optional(),
	maxPrice: z.coerce.number().positive().optional(),
});

export type HotelFiltersDto = z.infer<typeof hotelFiltersDto>;
