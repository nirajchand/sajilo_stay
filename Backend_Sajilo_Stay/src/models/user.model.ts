import mongoose, { Schema } from 'mongoose';
import type { User as UserType } from '../types/user.type.js';

// Compose the runtime user interface from the Zod-derived `User` type.
export interface IUser extends UserType {
  role?: 'USER' | 'ADMIN';
  // Stores the bcrypt hash of the password-reset OTP (never the plain code).
  resetPasswordToken?: string | null;
  resetPasswordExpires?: Date | null;
  // Set to true only after the OTP has been verified, gating the reset step.
  resetPasswordVerified?: boolean;
}

export type UserDocument = IUser & mongoose.Document;

const UserSchema = new Schema<UserDocument>(
  {
    fullName: { type: String, required: true },
    email: { type: String, required: true, unique: true, lowercase: true },
    password: { type: String, required: true },
    role: { type: String, enum: ['USER', 'ADMIN'], default: 'USER' },
    profile_image: { type: String, default: '' },
    resetPasswordToken: { type: String, default: null },
    resetPasswordExpires: { type: Date, default: null },
    resetPasswordVerified: { type: Boolean, default: false },
  },
  { timestamps: true }
);

export const UserModel = mongoose.model<UserDocument>('Users', UserSchema);

    