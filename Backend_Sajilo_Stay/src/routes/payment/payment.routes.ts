import { Router } from 'express';
import { PaymentController } from '../../controllers/payment.controller.js';
import { authenticate } from '../../middleware/auth.middleware.js';

const router = Router();
const paymentController = new PaymentController();

router.post(
	'/esewa/initiate',
	authenticate,
	paymentController.initiateEsewa.bind(paymentController)
);
router.post('/esewa/verify', authenticate, paymentController.verifyEsewa.bind(paymentController));
router.post('/demo-confirm', authenticate, paymentController.demoConfirm.bind(paymentController));

// Public landing pages eSewa redirects to after checkout (intercepted by the
// app's WebView). No auth — eSewa hits these in a plain browser context.
router.get('/esewa/success', paymentController.esewaSuccessPage.bind(paymentController));
router.get('/esewa/failure', paymentController.esewaFailurePage.bind(paymentController));

export const paymentRouter = router;
