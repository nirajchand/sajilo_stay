import nodemailer from 'nodemailer';
import { env } from '../config/env.js';

// A single reusable transporter. Created lazily so the app can boot even if
// email credentials are missing (only fails when an email is actually sent).
let transporter: nodemailer.Transporter | null = null;

function getTransporter(): nodemailer.Transporter {
  if (!env.email.user || !env.email.pass) {
    throw new Error('Email credentials are not configured (Email_User / Email_pass)');
  }
  if (!transporter) {
    transporter = nodemailer.createTransport({
      service: env.email.service, // e.g. 'gmail'
      auth: {
        user: env.email.user,
        // Gmail App Passwords are often shown with spaces ("abcd efgh ..."),
        // which must be removed before authenticating.
        pass: env.email.pass.replace(/\s+/g, ''),
      },
    });
  }
  return transporter;
}

export async function sendOtpEmail(to: string, otp: string): Promise<void> {
  const minutes = env.resetOtp.expiresInMinutes;
  const html = `
  <div style="font-family:'Segoe UI',Arial,sans-serif;max-width:480px;margin:0 auto;padding:32px 24px;background:#0f1611;color:#e8efe8;border-radius:16px;">
    <h2 style="margin:0 0 8px;color:#ffffff;font-size:22px;">Sajilo Stay</h2>
    <p style="margin:0 0 24px;color:#9fb0a0;font-size:14px;">Password reset verification code</p>
    <p style="margin:0 0 12px;font-size:14px;color:#c3c8c3;">Use the code below to reset your password. It expires in ${minutes} minutes.</p>
    <div style="text-align:center;margin:24px 0;">
      <span style="display:inline-block;letter-spacing:12px;font-size:34px;font-weight:700;color:#ffffff;background:#1c281e;padding:16px 24px;border-radius:14px;">${otp}</span>
    </div>
    <p style="margin:0;font-size:12px;color:#7b8a7c;">If you didn't request this, you can safely ignore this email.</p>
  </div>`;

  await getTransporter().sendMail({
    from: `"Sajilo Stay" <${env.email.from}>`,
    to,
    subject: 'Your Sajilo Stay password reset code',
    text: `Your Sajilo Stay password reset code is ${otp}. It expires in ${minutes} minutes.`,
    html,
  });
}
