import { Request, Response } from 'express';
import * as authService from '../services/auth.service.js';
import { createUserDto, loginUserDto, refreshTokenDto, logoutUserDto, forgotPasswordDto, verifyOtpDto, resetPasswordDto, CreateUserDto } from '../dtos/auth.dto.js';
import { z } from 'zod';

const googleSignInDto = z.object({ idToken: z.string().min(1) });

export class AuthController {
  async registerUser(req: Request, res: Response) {
    try {
      const parseData = createUserDto.safeParse(req.body);
      if (!parseData.success) {
        return res.status(400).json({
          success: false,
          message: parseData.error.format(),
        });
      }

      const userData: CreateUserDto = parseData.data;
      const newUser = await authService.registerUser(userData);

      return res.status(201).json({
        success: true,
        message: 'User registered successfully',
        user: {
          id: newUser.user._id,
          email: newUser.user.email,
          fullName: newUser.user.fullName,
          profile_image: newUser.user.profile_image,
        },
        accessToken: newUser.accessToken,
        refreshToken: newUser.refreshToken,
      });
    } catch (error: any) {
      return res.status(400).json({ success: false, message: error.message });
    }
  }

  async loginUser(req: Request, res: Response) {
    try {
      const parseData = loginUserDto.safeParse(req.body);
      if (!parseData.success) {
        return res.status(400).json({
          success: false,
          message: parseData.error.format(),
        });
      }

      const { email, password } = parseData.data;
      const result = await authService.loginUser(email, password);

      return res.status(200).json({
        success: true,
        message: 'Login successful',
        user: {
          id: result.user._id,
          email: result.user.email,
          fullName: result.user.fullName,
          role: result.user.role,
          profile_image: result.user.profile_image,
        },
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      });
    } catch (error: any) {
      return res.status(400).json({ success: false, message: error.message });
    }
  }

  async refreshToken(req: Request, res: Response) {
    try {
      const parseData = refreshTokenDto.safeParse(req.body);
      if (!parseData.success) {
        return res.status(400).json({
          success: false,
          message: parseData.error.format(),
        });
      }

      const { refreshToken } = parseData.data;
      const result = await authService.refreshAccessToken(refreshToken);

      return res.status(200).json({
        success: true,
        message: 'Access token refreshed',
        ...result,
      });
    } catch (error: any) {
      return res.status(401).json({ success: false, message: error.message });
    }
  }

  async logoutUser(req: Request, res: Response) {
    try {
      const parseData = logoutUserDto.safeParse(req.body);
      if (!parseData.success) {
        return res.status(400).json({
          success: false,
          message: parseData.error.format(),
        });
      }

      const { refreshToken } = parseData.data;
      await authService.logout(refreshToken);

      return res.status(204).send();
    } catch (error: any) {
      return res.status(400).json({ success: false, message: error.message });
    }
  }

  async forgotPassword(req: Request, res: Response) {
    try {
      const parseData = forgotPasswordDto.safeParse(req.body);
      if (!parseData.success) {
        return res.status(400).json({
          success: false,
          message: parseData.error.format(),
        });
      }

      const { email } = parseData.data;
      await authService.forgotPassword(email);

      // Always respond success — we don't reveal whether the email exists.
      return res.status(200).json({
        success: true,
        message: 'If an account exists for that email, a reset code has been sent',
      });
    } catch (error: any) {
      return res.status(400).json({ success: false, message: error.message });
    }
  }

  async verifyOtp(req: Request, res: Response) {
    try {
      const parseData = verifyOtpDto.safeParse(req.body);
      if (!parseData.success) {
        return res.status(400).json({
          success: false,
          message: parseData.error.format(),
        });
      }

      const { email, otp } = parseData.data;
      await authService.verifyResetOtp(email, otp);

      return res.status(200).json({
        success: true,
        message: 'OTP verified',
      });
    } catch (error: any) {
      return res.status(400).json({ success: false, message: error.message });
    }
  }

  async resetPassword(req: Request, res: Response) {
    try {
      const parseData = resetPasswordDto.safeParse(req.body);
      if (!parseData.success) {
        return res.status(400).json({
          success: false,
          message: parseData.error.format(),
        });
      }

      const { email, newPassword } = parseData.data;
      await authService.resetPassword(email, newPassword);

      return res.status(200).json({
        success: true,
        message: 'Password reset successful',
      });
    } catch (error: any) {
      return res.status(400).json({ success: false, message: error.message });
    }
  }

  async googleSignIn(req: Request, res: Response) {
    try {
      const parseData = googleSignInDto.safeParse(req.body);
      if (!parseData.success) {
        return res.status(400).json({ success: false, message: 'idToken is required' });
      }

      const { idToken } = parseData.data;
      const result = await authService.googleSignIn(idToken);

      return res.status(200).json({
        success: true,
        message: 'Google sign-in successful',
        user: {
          id: result.user._id,
          email: result.user.email,
          fullName: result.user.fullName,
          role: result.user.role,
          profile_image: result.user.profile_image,
        },
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      });
    } catch (error: any) {
      return res.status(401).json({ success: false, message: error.message });
    }
  }
}

export const authController = new AuthController();
