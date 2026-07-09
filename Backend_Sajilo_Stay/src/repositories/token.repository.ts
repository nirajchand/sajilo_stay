import { RefreshTokenModel } from '../models/refreshToken.model.js';
import mongoose from 'mongoose';

export async function createRefreshToken(userId: string, token: string, expiresAt: Date) {
  const doc = new RefreshTokenModel({ user: new mongoose.Types.ObjectId(userId), token, expiresAt });
  return doc.save();
}

export async function findRefreshToken(token: string) {
  return RefreshTokenModel.findOne({ token }).exec();
}

export async function revokeRefreshToken(token: string) {
  return RefreshTokenModel.findOneAndUpdate({ token }, { revoked: true }).exec();
}

export async function deleteRefreshTokensForUser(userId: string) {
  return RefreshTokenModel.deleteMany({ user: userId }).exec();
}
