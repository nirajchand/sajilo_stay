import { Router, type Request, type Response } from 'express';
import { ReviewController } from '../../controllers/review.controller.js';
import { authenticate, authorizeAdmin } from '../../middleware/auth.middleware.js';

const router = Router();
const reviewController = new ReviewController();

function isAdminReviewsRoute(req: Request): boolean {
	return req.baseUrl.endsWith('/admin/reviews');
}

router.post('/', authenticate, reviewController.createReview.bind(reviewController));
router.put('/:id', authenticate, reviewController.updateReview.bind(reviewController));
router.delete('/:id', authenticate, (req: Request, res: Response) => {
	if (isAdminReviewsRoute(req)) {
		return authorizeAdmin(req, res, () => reviewController.deleteAnyReview(req, res));
	}

	return reviewController.deleteReview(req, res);
});

export const reviewRouter = router;
