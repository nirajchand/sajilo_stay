import { z } from 'zod';
import { favouriteSchema } from '../types/favourite.types.js';

export const addFavouriteDto = favouriteSchema;
export type AddFavouriteDto = z.infer<typeof addFavouriteDto>;
