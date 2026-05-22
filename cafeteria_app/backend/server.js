const express = require('express');
const path = require('path');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const authRoutes = require('./routes/auth_routes');
const menuRoutes = require('./routes/menu_routes');
const orderRoutes = require('./routes/order_routes');
const walletRoutes = require('./routes/wallet_routes');
const globalErrorHandler = require('./controllers/error_controller');
const AppError = require('./utils/app_error');

const app = express();

// 1. Security Headers
app.use(helmet());

// 2. Rate Limiting (Prevent Brute Force)
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 20, // Limit each IP to 20 requests per auth window
  message: { success: false, message: 'Too many login attempts, please try again after 15 minutes' },
  standardHeaders: true,
  legacyHeaders: false,
});

app.use(cors());
app.use(express.json());

// Serve uploaded files (e.g. profile avatars) statically. Override helmet's
// default same-origin CORP so the images load when fetched from the app's
// separate origin (mobile clients and Flutter web).
app.use(
  '/uploads',
  helmet({ crossOriginResourcePolicy: { policy: 'cross-origin' } }),
  express.static(path.join(__dirname, 'uploads'))
);

// Apply rate limiter specifically to auth routes
app.use('/api/auth', authLimiter, authRoutes);

app.use('/api/menu', menuRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/wallet', walletRoutes);

// Handle undefined routes
app.all('*', (req, res, next) => {
  next(new AppError(`Can't find ${req.originalUrl} on this server!`, 404));
});

// Global Error Handler
app.use(globalErrorHandler);

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});
