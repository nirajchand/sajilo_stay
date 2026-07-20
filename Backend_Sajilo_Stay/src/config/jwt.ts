import jwt from 'jsonwebtoken';
import { env } from './env.js';

export function signAccessToken(payload: object) {
  return jwt.sign(payload, env.jwtAccessSecret as jwt.Secret, { expiresIn: env.accessTokenExpiresIn } as any);
}

export function signRefreshToken(payload: object) {
  return jwt.sign(payload, env.jwtRefreshSecret as jwt.Secret, { expiresIn: `${env.refreshTokenExpiresInDays}d` } as any);
}

export function verifyAccessToken(token: string) {
  return jwt.verify(token, env.jwtAccessSecret as jwt.Secret);
}

export function verifyRefreshToken(token: string) {
  return jwt.verify(token, env.jwtRefreshSecret as jwt.Secret);
}
