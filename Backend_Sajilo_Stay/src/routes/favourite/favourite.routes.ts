import { Router } from 'express';
import { FavouriteController } from '../../controllers/favourite.controller.js';
import { authenticate } from '../../middleware/auth.middleware.js';

const router = Router();
const favouriteController = new FavouriteController();

router.get('/', authenticate, favouriteController.getMyFavourites.bind(favouriteController));
router.post('/', authenticate, favouriteController.addFavourite.bind(favouriteController));
router.delete('/:hotelId', authenticate, favouriteController.removeFavourite.bind(favouriteController));

export const favouriteRouter = router;
