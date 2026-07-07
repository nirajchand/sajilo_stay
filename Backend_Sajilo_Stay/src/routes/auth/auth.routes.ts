import { Router } from 'express';
import { AuthController } from '../../controllers/auth.controller.js';
const router = Router();
const authController = new AuthController();

router.post('/register', authController.registerUser.bind(authController));
router.post('/login', authController.loginUser.bind(authController));
router.post('/refresh', authController.refreshToken.bind(authController));
router.post('/logout', authController.logoutUser.bind(authController));
router.post('/forgot-password', authController.forgotPassword.bind(authController));
router.post('/verify-otp', authController.verifyOtp.bind(authController));
router.post('/reset-password', authController.resetPassword.bind(authController));
router.post('/google', authController.googleSignIn.bind(authController));

export default router;
