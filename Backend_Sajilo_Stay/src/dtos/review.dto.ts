import { z } from 'zod';

export const createReviewDto = z.object({
	hotelId: z.string().min(1),
	bookingId: z.string().min(1),
	rating: z.number().int().min(1).max(5),
	comment: z.string().max(500).optional(),
});

export type CreateReviewDto = z.infer<typeof createReviewDto>;

export const updateReviewDto = z.object({
	rating: z.number().int().min(1).max(5).optional(),
	comment: z.string().max(500).optional(),
});

export type UpdateReviewDto = z.infer<typeof updateReviewDto>;
