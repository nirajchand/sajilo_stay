import { z } from 'zod';

export const createRoomDto = z.object({
	type: z.string().min(1),
	capacity: z.number().int().positive(),
	pricePerNight: z.number().positive(),
	images: z.array(z.string().url()).optional(),
});

export type CreateRoomDto = z.infer<typeof createRoomDto>;

export const updateRoomDto = createRoomDto.partial();
export type UpdateRoomDto = z.infer<typeof updateRoomDto>;

export const availabilityQueryDto = z
	.object({
		checkIn: z.coerce.date(),
		checkOut: z.coerce.date(),
	})
	.refine((data) => data.checkOut > data.checkIn, {
		message: 'checkOut must be after checkIn',
	});

export type AvailabilityQueryDto = z.infer<typeof availabilityQueryDto>;
