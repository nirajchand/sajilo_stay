import crypto from 'node:crypto';
import { env } from '../config/env.js';

/**
 * eSewa ePay v2 helper.
 *
 * Signing rule (per eSewa docs): build a message of `key=value` pairs joined
 * by commas in the exact order given by `signed_field_names`, then
 * HMAC-SHA256 it with the merchant secret key and base64-encode the digest.
 */

export type EsewaFormFields = {
	amount: string;
	tax_amount: string;
	total_amount: string;
	transaction_uuid: string;
	product_code: string;
	product_service_charge: string;
	product_delivery_charge: string;
	success_url: string;
	failure_url: string;
	signed_field_names: string;
	signature: string;
};

// eSewa's decoded success payload.
export type EsewaCallbackData = {
	transaction_code: string;
	status: string;
	total_amount: string;
	transaction_uuid: string;
	product_code: string;
	signed_field_names: string;
	signature: string;
	[key: string]: string;
};

function sign(message: string): string {
	return crypto
		.createHmac('sha256', env.esewa.secretKey)
		.update(message)
		.digest('base64');
}

/**
 * Build the fully-signed set of form fields the client posts to eSewa.
 * `totalAmount` must match the booking total exactly — eSewa signs over it.
 */
export function buildPaymentFields(transactionUuid: string, totalAmount: number): EsewaFormFields {
	const amount = totalAmount.toString();
	const taxAmount = '0';
	const total = totalAmount.toString();
	const productCode = env.esewa.merchantCode;
	const signedFieldNames = 'total_amount,transaction_uuid,product_code';

	const message = `total_amount=${total},transaction_uuid=${transactionUuid},product_code=${productCode}`;
	const signature = sign(message);

	return {
		amount,
		tax_amount: taxAmount,
		total_amount: total,
		transaction_uuid: transactionUuid,
		product_code: productCode,
		product_service_charge: '0',
		product_delivery_charge: '0',
		success_url: env.esewa.successUrl,
		failure_url: env.esewa.failureUrl,
		signed_field_names: signedFieldNames,
		signature,
	};
}

export function getFormUrl(): string {
	return env.esewa.formUrl;
}

/**
 * Decode the base64 `data` query param eSewa appends to the success URL.
 */
export function decodeCallbackData(rawBase64: string): EsewaCallbackData {
	// Some clients pass the value through form-url decoding, which turns the
	// base64 '+' characters into spaces. Valid base64 never contains spaces,
	// so restoring them to '+' safely repairs that corruption.
	const repaired = rawBase64.replace(/ /g, '+');
	const json = Buffer.from(repaired, 'base64').toString('utf-8');
	return JSON.parse(json) as EsewaCallbackData;
}

/**
 * Verify the callback signature by reconstructing the signed message from the
 * fields named in `signed_field_names`, in order.
 */
export function verifyCallbackSignature(data: EsewaCallbackData): boolean {
	const fieldNames = data.signed_field_names.split(',').map((name) => name.trim());
	const message = fieldNames.map((name) => `${name}=${data[name] ?? ''}`).join(',');
	const expected = sign(message);
	if (expected !== data.signature) {
		console.warn('[eSewa sign] message:', message);
		console.warn('[eSewa sign] expected:', expected, '| received:', data.signature);
	}
	return expected === data.signature;
}
