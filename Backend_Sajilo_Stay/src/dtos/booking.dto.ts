import { z } from 'zod';

export const createBookingDto = z
	.object({
		roomId: z.string().min(1),
		checkIn: z.string().datetime(),
		checkOut: z.string().datetime(),
		guests: z.number().int().min(1),
		paymentMethod: z.enum(['ESEWA', 'PAY_AT_HOTEL']).default('PAY_AT_HOTEL'),
	})
	.refine((data) => new Date(data.checkOut) > new Date(data.checkIn), {
		message: 'checkOut must be after checkIn',
		path: ['checkOut'],
	});

export type CreateBookingDto = z.infer<typeof createBookingDto>;

export const updateBookingStatusDto = z.object({
	status: z.enum(['PENDING', 'CONFIRMED', 'CANCELLED', 'COMPLETED']),
});

export type UpdateBookingStatusDto = z.infer<typeof updateBookingStatusDto>;
