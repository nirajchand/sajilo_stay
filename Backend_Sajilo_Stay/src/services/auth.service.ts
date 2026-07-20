import bcrypt from 'bcryptjs';
import crypto from 'crypto';
import { OAuth2Client } from 'google-auth-library';
import { findUserByEmail, createUser, setResetTokenForUser, findUserById, markResetVerified, updatePasswordAndClearReset } from '../repositories/user.repository.js';
import { createRefreshToken, findRefreshToken, revokeRefreshToken, deleteRefreshTokensForUser } from '../repositories/token.repository.js';
import { signAccessToken, signRefreshToken, verifyRefreshToken } from '../config/jwt.js';
import { env } from '../config/env.js';
import { sendOtpEmail } from './mailer.service.js';
import { CreateUserDto } from '../dtos/auth.dto.js';

const googleOAuthClient = new OAuth2Client();

const SALT_ROUNDS = 10;

export async function registerUser(userData:CreateUserDto) {
  const existing = await findUserByEmail(userData.email);
  if (existing) throw new Error('Email already in use');

  const { confirmPassword: _confirmPassword, ...registrationData } = userData;
  const hashed = await bcrypt.hash(userData.password, SALT_ROUNDS);
  const user = await createUser({
    ...registrationData,
    password: hashed,
    profile_image: registrationData.profile_image ?? '',
  });

  const accessToken = signAccessToken({ sub: user._id.toString(), role: user.role });
  const refreshToken = signRefreshToken({ sub: user._id.toString() });

  const refreshExpires = new Date();
  refreshExpires.setDate(refreshExpires.getDate() + env.refreshTokenExpiresInDays);
  await createRefreshToken(user._id.toString(), refreshToken, refreshExpires);

  return { user, accessToken, refreshToken };
}

export async function loginUser(email: string, password: string) {
  const user = await findUserByEmail(email);
  if (!user) throw new Error('Invalid credentials');

  const ok = await bcrypt.compare(password, user.password);
  if (!ok) throw new Error('Invalid credentials');

  const accessToken = signAccessToken({ sub: user._id.toString(), role: user.role });
  const refreshToken = signRefreshToken({ sub: user._id.toString() });

  const refreshExpires = new Date();
  refreshExpires.setDate(refreshExpires.getDate() + env.refreshTokenExpiresInDays);
  await createRefreshToken(user._id.toString(), refreshToken, refreshExpires);

  return { user, accessToken, refreshToken };
}

export async function refreshAccessToken(refreshToken: string) {
  // verify signature
  let payload: any;
  try {
    payload = verifyRefreshToken(refreshToken) as any;
  } catch (err) {
    throw new Error('Invalid refresh token');
  }

  const stored = await findRefreshToken(refreshToken);
  if (!stored || stored.revoked) throw new Error('Refresh token revoked');
  if (stored.expiresAt < new Date()) throw new Error('Refresh token expired');

  const user = await findUserById(payload.sub);
  if (!user) {
    throw new Error('Invalid refresh token');
  }

  const accessToken = signAccessToken({ sub: payload.sub, role: user.role });
  return { accessToken };
}

export async function logout(refreshToken: string) {
  await revokeRefreshToken(refreshToken);
}

// Generate a numeric OTP of the configured length (e.g. "4821").
function generateOtp(length: number): string {
  const max = 10 ** length;
  const num = crypto.randomInt(0, max);
  return num.toString().padStart(length, '0');
}

export async function googleSignIn(idToken: string) {
  const ticket = await googleOAuthClient.verifyIdToken({ idToken });
  const payload = ticket.getPayload();
  if (!payload || !payload.email) throw new Error('Invalid Google token');

  const { email, name, picture } = payload;

  let user = await findUserByEmail(email);
  if (!user) {
    // First-time Google sign-in: create an account with a random password.
    const randomPassword = crypto.randomBytes(32).toString('hex');
    const hashed = await bcrypt.hash(randomPassword, SALT_ROUNDS);
    user = await createUser({
      fullName: name ?? email.split('@')[0],
      email,
      password: hashed,
      profile_image: picture ?? '',
    });
  }

  const accessToken = signAccessToken({ sub: user._id.toString(), role: user.role });
  const refreshToken = signRefreshToken({ sub: user._id.toString() });

  const refreshExpires = new Date();
  refreshExpires.setDate(refreshExpires.getDate() + env.refreshTokenExpiresInDays);
  await createRefreshToken(user._id.toString(), refreshToken, refreshExpires);

  return { user, accessToken, refreshToken };
}

export async function forgotPassword(email: string) {
  const user = await findUserByEmail(email);
  // Don't reveal whether the account exists — return silently either way.
  if (!user) return;

  const otp = generateOtp(env.resetOtp.length);
  const hashedOtp = await bcrypt.hash(otp, SALT_ROUNDS);

  const expires = new Date();
  expires.setMinutes(expires.getMinutes() + env.resetOtp.expiresInMinutes);

  await setResetTokenForUser(user._id.toString(), hashedOtp, expires);

  // Deliver the plain OTP via email. We never persist the plain value.
  try {
    await sendOtpEmail(user.email, otp);
  } catch (err) {
    // In dev, don't let broken SMTP block the flow — surface the OTP in the
    // server console so the reset can still be completed/tested.
    if (env.resetOtp.devMode) {
      console.warn(
        `\n[reset-otp] Email delivery failed (${(err as Error).message.split('\n')[0]}).` +
          `\n[reset-otp] DEV MODE: OTP for ${user.email} is ${otp} (expires in ${env.resetOtp.expiresInMinutes} min)\n`
      );
      return;
    }
    throw err;
  }
}

export async function verifyResetOtp(email: string, otp: string) {
  const user = await findUserByEmail(email);
  if (!user || !user.resetPasswordToken) throw new Error('Invalid or expired code');
  if (!user.resetPasswordExpires || user.resetPasswordExpires < new Date()) {
    throw new Error('Invalid or expired code');
  }

  const ok = await bcrypt.compare(otp, user.resetPasswordToken);
  if (!ok) throw new Error('Invalid or expired code');

  await markResetVerified(user._id.toString());
}

export async function resetPassword(email: string, newPassword: string) {
  const user = await findUserByEmail(email);
  if (!user || !user.resetPasswordVerified) throw new Error('OTP not verified');
  if (!user.resetPasswordExpires || user.resetPasswordExpires < new Date()) {
    throw new Error('Reset session expired, please request a new code');
  }

  const hashed = await bcrypt.hash(newPassword, SALT_ROUNDS);
  await updatePasswordAndClearReset(user._id.toString(), hashed);
}
