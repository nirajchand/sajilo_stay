import { Router } from 'express';
import { HotelController } from '../../controllers/hotel.controller.js';
import { RoomController } from '../../controllers/room.controller.js';
import { ReviewController } from '../../controllers/review.controller.js';
import { hotelUpload } from '../../middleware/hotel-upload.middleware.js';
import { authenticate, authorizeAdmin, optionalAuthenticate } from '../../middleware/auth.middleware.js';

const router = Router();
const hotelController = new HotelController();
const roomController = new RoomController();
const reviewController = new ReviewController();

router.get('/', optionalAuthenticate, hotelController.getHotels.bind(hotelController));
router.post(
	'/create-hotel',
	authenticate,
	authorizeAdmin,
	hotelUpload,
	hotelController.createHotel.bind(hotelController)
);
router.get('/:hotelId/rooms', roomController.getRoomsByHotel.bind(roomController));
router.post(
	'/:hotelId/rooms',
	authenticate,
	authorizeAdmin,
	roomController.createRoom.bind(roomController)
);
router.get('/:id/reviews', reviewController.getHotelReviews.bind(reviewController));
router.get('/:id', optionalAuthenticate, hotelController.getHotelById.bind(hotelController));
router.put(
	'/:id',
	authenticate,
	authorizeAdmin,
	hotelController.updateHotel.bind(hotelController)
);
router.delete(
	'/:id',
	authenticate,
	authorizeAdmin,
	hotelController.deleteHotel.bind(hotelController)
);

export default router;
