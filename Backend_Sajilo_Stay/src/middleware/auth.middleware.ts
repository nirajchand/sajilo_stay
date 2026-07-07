import type { NextFunction, Request, Response } from 'express';
import { verifyAccessToken } from '../config/jwt.js';

type AccessTokenPayload = {
	sub?: string;
	role?: 'USER' | 'ADMIN';
};

function getBearerToken(authorizationHeader: string | undefined): string | null {
	if (!authorizationHeader?.startsWith('Bearer ')) {
		return null;
	}

	const token = authorizationHeader.slice('Bearer '.length).trim();
	return token.length > 0 ? token : null;
}

export function authenticate(req: Request, res: Response, next: NextFunction): void {
	const token = getBearerToken(req.headers.authorization);

	if (!token) {
		res.status(401).json({
			success: false,
			message: 'Authentication required',
		});
		return;
	}

	try {
		const payload = verifyAccessToken(token) as AccessTokenPayload;

		if (!payload.sub) {
			res.status(401).json({
				success: false,
				message: 'Invalid access token',
			});
			return;
		}

		req.user = {
			userId: payload.sub,
			role: payload.role ?? 'USER',
		};

		next();
	} catch {
		res.status(401).json({
			success: false,
			message: 'Invalid or expired access token',
		});
	}
}

export function optionalAuthenticate(req: Request, _res: Response, next: NextFunction): void {
	const token = getBearerToken(req.headers.authorization);

	if (!token) {
		next();
		return;
	}

	try {
		const payload = verifyAccessToken(token) as AccessTokenPayload;

		if (payload.sub) {
			req.user = {
				userId: payload.sub,
				role: payload.role ?? 'USER',
			};
		}
	} catch {
		// Ignore invalid tokens for optional auth routes.
	}

	next();
}

export function authorizeAdmin(req: Request, res: Response, next: NextFunction): void {
	if (!req.user) {
		res.status(401).json({
			success: false,
			message: 'Authentication required',
		});
		return;
	}

	if (req.user.role !== 'ADMIN') {
		res.status(403).json({
			success: false,
			message: 'Admin access required',
		});
		return;
	}

	next();
}
