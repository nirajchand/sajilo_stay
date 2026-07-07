import { Router, type Request, type Response, type NextFunction } from 'express';
import { BookingController } from '../../controllers/booking.controller.js';
import { authenticate, authorizeAdmin } from '../../middleware/auth.middleware.js';

const router = Router();
const bookingController = new BookingController();

function isAdminBookingsRoute(req: Request): boolean {
	return req.baseUrl.endsWith('/admin/bookings');
}

router.post('/', authenticate, bookingController.createBooking.bind(bookingController));

router.get('/', authenticate, (req: Request, res: Response, next: NextFunction) => {
	if (isAdminBookingsRoute(req)) {
		return authorizeAdmin(req, res, () => bookingController.getAllBookings(req, res));
	}

	return bookingController.getMyBookings(req, res);
});

router.get('/:id', authenticate, bookingController.getBookingById.bind(bookingController));
router.patch('/:id/cancel', authenticate, bookingController.cancelBooking.bind(bookingController));
router.patch(
	'/:id/status',
	authenticate,
	authorizeAdmin,
	bookingController.updateBookingStatus.bind(bookingController)
);

export const bookingRouter = router;
