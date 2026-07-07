import mongoose, { Schema } from 'mongoose';

export interface IRefreshToken extends mongoose.Document {
  user: mongoose.Types.ObjectId;
  token: string;
  expiresAt: Date;
  createdAt: Date;
  revoked?: boolean;
}

const RefreshTokenSchema = new Schema<IRefreshToken>(
  {
    user: { type: Schema.Types.ObjectId, ref: 'Users', required: true },
    token: { type: String, required: true, unique: true },
    expiresAt: { type: Date, required: true },
    revoked: { type: Boolean, default: false },
  },
  { timestamps: { createdAt: true, updatedAt: false } }
);

export const RefreshTokenModel = mongoose.model<IRefreshToken>('RefreshToken', RefreshTokenSchema);
