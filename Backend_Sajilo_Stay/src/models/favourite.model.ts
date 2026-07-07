import mongoose, { Schema } from 'mongoose';

export interface IFavourite {
	_id: mongoose.Types.ObjectId;
	userId: mongoose.Types.ObjectId;
	hotelId: mongoose.Types.ObjectId;
}

export type FavouriteDocument = IFavourite & mongoose.Document;

const FavouriteSchema = new Schema<FavouriteDocument>(
	{
		userId: { type: Schema.Types.ObjectId, ref: 'Users', required: true },
		hotelId: { type: Schema.Types.ObjectId, ref: 'Hotels', required: true },
	},
	{ timestamps: true }
);

FavouriteSchema.index({ userId: 1, hotelId: 1 }, { unique: true });

export const FavouriteModel = mongoose.model<FavouriteDocument>('Favourites', FavouriteSchema);
