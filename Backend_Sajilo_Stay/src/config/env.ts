import dotenv from 'dotenv';
import path from 'path';

dotenv.config();

function parsePort(value: string | undefined): number {
	if (!value) {
		return 3000;
	}

	const parsedPort = Number(value);

	if (!Number.isInteger(parsedPort) || parsedPort <= 0) {
		throw new Error('PORT must be a positive integer');
	}

	return parsedPort;
}

export const env = {
	port: parsePort(process.env.PORT),
	mongoUri: process.env.MONGODB_URI ?? '',
	mongoDbName: process.env.MONGODB_DB_NAME ?? 'sajilo_stay',
	jwtAccessSecret: process.env.JWT_ACCESS_SECRET ?? 'change_this_access_secret',
	jwtRefreshSecret: process.env.JWT_REFRESH_SECRET ?? 'change_this_refresh_secret',
	accessTokenExpiresIn: process.env.ACCESS_TOKEN_EXPIRES_IN ?? '15m',
	refreshTokenExpiresInDays: Number(process.env.REFRESH_TOKEN_EXPIRES_DAYS ?? '7'),
	// Transactional email (Gmail SMTP via App Password). Used to deliver
	// password-reset OTPs. See .env: Email_service / Email_User / Email_pass.
	email: {
		service: process.env.Email_service ?? 'gmail',
		user: process.env.Email_User ?? '',
		pass: process.env.Email_pass ?? '',
		from: process.env.Email_From ?? process.env.Email_User ?? '',
	},
	// Password-reset OTP settings.
	resetOtp: {
		length: Number(process.env.RESET_OTP_LENGTH ?? '4'),
		expiresInMinutes: Number(process.env.RESET_OTP_EXPIRES_MINUTES ?? '10'),
		// When email delivery fails in dev, log the OTP to the server console
		// and still succeed, so the reset flow is testable without working SMTP.
		// Defaults on outside production. Set RESET_OTP_DEV_MODE=false to require email.
		devMode:
			(process.env.RESET_OTP_DEV_MODE ??
				(process.env.NODE_ENV === 'production' ? 'false' : 'true')) === 'true',
	},
	// eSewa ePay v2 — defaults are the official sandbox/test credentials.
	esewa: {
		merchantCode: process.env.ESEWA_MERCHANT_CODE ?? 'EPAYTEST',
		secretKey: process.env.ESEWA_SECRET_KEY ?? '8gBm/:&EnhH.1/q',
		formUrl:
			process.env.ESEWA_FORM_URL ?? 'https://rc-epay.esewa.com.np/api/epay/main/v2/form',
		// Sentinel redirect URLs — the mobile WebView intercepts these by path,
		// so they only need a stable, recognisable path segment.
		successUrl:
			process.env.ESEWA_SUCCESS_URL ?? 'https://sajilostay.local/payment/esewa/success',
		failureUrl:
			process.env.ESEWA_FAILURE_URL ?? 'https://sajilostay.local/payment/esewa/failure',
	},
};