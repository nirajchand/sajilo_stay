import type { Request } from 'express';

/**
 * Convert a stored image filename into a fully-qualified URL the client can
 * load. Already-absolute URLs are returned untouched (backwards compatible
 * with older records that stored full URLs).
 */
export function toImageUrl(req: Request, path: string): string {
	if (!path) return '';
	if (path.startsWith('http')) return path;
	return `${req.protocol}://${req.get('host')}/uploads/hotels/${path}`;
}

/**
 * Map a populated booking's nested hotel/room image fields to full URLs.
 */
export function transformBooking(booking: any, req: Request): any {
	if (!booking) return booking;

	const hotel = booking.hotelId;
	if (hotel && typeof hotel === 'object' && Array.isArray(hotel.gallery)) {
		hotel.gallery = hotel.gallery.map((img: string) => toImageUrl(req, img));
	}

	const room = booking.roomId;
	if (room && typeof room === 'object' && Array.isArray(room.images)) {
		room.images = room.images.map((img: string) => toImageUrl(req, img));
	}

	return booking;
}
