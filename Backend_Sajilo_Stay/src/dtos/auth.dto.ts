import { z } from 'zod';
import { UserSchema } from '../types/user.type.js';

export const createUserDto = UserSchema.pick({
  fullName: true,
  email: true,
  password: true,
  profile_image: true,
  role: true,
}).extend({
  confirmPassword: z.string().min(6),
}).refine((data) => data.password ===data.confirmPassword, {
  message: "Passwords don't match",
});
export type CreateUserDto = z.infer<typeof createUserDto>;

export const loginUserDto = UserSchema.pick({
  email: true,
  password: true,
});
export type LoginUserDto = z.infer<typeof loginUserDto>;

export const refreshTokenDto = z.object({
  refreshToken: z.string().min(1),
});
export type RefreshTokenDto = z.infer<typeof refreshTokenDto>;

export const logoutUserDto = refreshTokenDto;
export type LogoutUserDto = RefreshTokenDto;

export const forgotPasswordDto = z.object({
  email: z.string().email(),
});
export type ForgotPasswordDto = z.infer<typeof forgotPasswordDto>;

export const verifyOtpDto = z.object({
  email: z.string().email(),
  otp: z.string().min(4).max(8),
});
export type VerifyOtpDto = z.infer<typeof verifyOtpDto>;

export const resetPasswordDto = z.object({
  email: z.string().email(),
  newPassword: z.string().min(6),
});
export type ResetPasswordDto = z.infer<typeof resetPasswordDto>;
