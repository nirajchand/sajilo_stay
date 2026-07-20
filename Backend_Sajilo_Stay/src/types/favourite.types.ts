import { z } from 'zod';

export const favouriteSchema = z.object({
	hotelId: z.string().min(1, 'Hotel id is required'),
});

export type FavouriteType = z.infer<typeof favouriteSchema>;
