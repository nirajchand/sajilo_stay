import { Router } from 'express';
import { RoomController } from '../../controllers/room.controller.js';
import { authenticate, authorizeAdmin } from '../../middleware/auth.middleware.js';

const router = Router();
const roomController = new RoomController();

router.get('/:id/availability', roomController.checkAvailability.bind(roomController));
router.get('/:id', roomController.getRoomById.bind(roomController));
router.put('/:id', authenticate, authorizeAdmin, roomController.updateRoom.bind(roomController));
router.delete('/:id', authenticate, authorizeAdmin, roomController.deleteRoom.bind(roomController));

export const roomRouter = router;
