import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import path from 'node:path';
import authRouter from './routes/auth/auth.routes.js';
import hotelRouter from './routes/hotel/hotel.routes.js';
import { roomRouter } from './routes/room/room.routes.js';
import { bookingRouter } from './routes/booking/booking.routes.js';
import { reviewRouter } from './routes/review/review.routes.js';
import { favouriteRouter } from './routes/favourite/favourite.routes.js';
import { paymentRouter } from './routes/payment/payment.routes.js';

const app = express();

app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(morgan('dev'));
app.use('/uploads', (_req, res, next) => {
	res.setHeader('Cross-Origin-Resource-Policy', 'cross-origin');
	next();
}, express.static(path.join(process.cwd(), 'uploads')));

app.get('/health', (_request, response) => {
	response.status(200).json({
		status: 'ok',
		message: 'Sajilo Stay backend is running',
	});
});

app.use('/api/v1/auth', authRouter);
app.use('/api/v1/hotels', hotelRouter);
app.use('/api/v1/rooms', roomRouter);
app.use('/api/v1/bookings', bookingRouter);
app.use('/api/v1/payments', paymentRouter);
app.use('/api/v1/reviews', reviewRouter);
app.use('/api/v1/admin/bookings', bookingRouter);
app.use('/api/v1/admin/reviews', reviewRouter);
app.use('/api/v1/favourites', favouriteRouter);

app.use((_request, response) => {
	response.status(404).json({
		status: 'error',
		message: 'Route not found',
	});
});

app.use(
	(error: unknown, _request: express.Request, response: express.Response, _next: express.NextFunction) => {
		console.error(error);
		response.status(500).json({
			status: 'error',
			message: 'Internal server error',
		});
	}
);

export { app };
