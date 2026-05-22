const path = require('path');
const fs = require('fs');
const db = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const catchAsync = require('../utils/catch_async');
const AppError = require('../utils/app_error');

exports.register = catchAsync(async (req, res, next) => {
  const { username, email, password, role } = req.body;

  if (!username || !email || !password || !role) {
    return next(new AppError('All fields are required', 400));
  }

  const userExists = await db.query('SELECT * FROM users WHERE email = $1 OR username = $2', [email, username]);
  if (userExists.rows.length > 0) {
    return next(new AppError('Username or Email already registered', 400));
  }

  const hashedPassword = await bcrypt.hash(password, 12);
  const result = await db.query(
    'INSERT INTO users (username, email, password, role) VALUES ($1, $2, $3, $4) RETURNING id, username, email, role',
    [username.trim(), email.toLowerCase().trim(), hashedPassword, role]
  );
  
  res.status(201).json({ success: true, data: result.rows[0] });
});

exports.login = catchAsync(async (req, res, next) => {
  const { username, password } = req.body;

  if (!username || !password) {
    return next(new AppError('Please provide both username and password', 400));
  }

  const result = await db.query('SELECT * FROM users WHERE username = $1', [username]);
  
  if (result.rows.length === 0 || !(await bcrypt.compare(password, result.rows[0].password))) {
    return next(new AppError('Invalid username or password', 401));
  }

  const user = result.rows[0];
  const token = jwt.sign({ id: user.id, role: user.role }, process.env.JWT_SECRET, { expiresIn: '2h' });

  res.status(200).json({
    success: true,
    data: {
      token,
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        role: user.role,
        avatar_url: user.avatar_url,
        registration_number: user.registration_number,
        year_of_study: user.year_of_study,
      }
    }
  });
});

// PATCH /api/auth/me/avatar — authenticated user uploads/replaces their profile picture.
// Expects a multipart form with a single "avatar" image field (handled upstream by
// the upload middleware, which sets req.file). Old avatar file is removed on replace.
exports.updateAvatar = catchAsync(async (req, res, next) => {
  if (!req.file) {
    return next(new AppError('No image file provided', 400));
  }

  const avatarUrl = `/uploads/avatars/${req.file.filename}`;

  // Fetch the previous avatar so we can delete its file after a successful update.
  const existing = await db.query('SELECT avatar_url FROM users WHERE id = $1', [req.user.id]);
  if (existing.rows.length === 0) {
    return next(new AppError('User no longer exists', 404));
  }

  const result = await db.query(
    'UPDATE users SET avatar_url = $1 WHERE id = $2 RETURNING id, username, email, role, avatar_url, registration_number, year_of_study',
    [avatarUrl, req.user.id]
  );

  // Best-effort cleanup of the replaced file; never fail the request over it.
  const oldUrl = existing.rows[0].avatar_url;
  if (oldUrl && oldUrl.startsWith('/uploads/avatars/') && oldUrl !== avatarUrl) {
    const oldPath = path.join(__dirname, '..', oldUrl);
    fs.unlink(oldPath, () => {});
  }

  res.status(200).json({ success: true, data: result.rows[0] });
});

// PATCH /api/auth/me — authenticated user updates editable profile fields.
// Only registration_number and year_of_study are editable here; email/username/
// role are intentionally not changeable through this endpoint.
exports.updateProfile = catchAsync(async (req, res, next) => {
  const { registration_number, year_of_study } = req.body;

  let year = null;
  if (year_of_study !== undefined && year_of_study !== null && year_of_study !== '') {
    year = parseInt(year_of_study, 10);
    if (Number.isNaN(year) || year < 1 || year > 8) {
      return next(new AppError('Year of study must be a number between 1 and 8', 400));
    }
  }

  const regNumber =
    typeof registration_number === 'string' && registration_number.trim() !== ''
      ? registration_number.trim()
      : null;

  const result = await db.query(
    'UPDATE users SET registration_number = $1, year_of_study = $2 WHERE id = $3 RETURNING id, username, email, role, avatar_url, registration_number, year_of_study',
    [regNumber, year, req.user.id]
  );

  if (result.rows.length === 0) {
    return next(new AppError('User no longer exists', 404));
  }

  res.status(200).json({ success: true, data: result.rows[0] });
});

exports.forgotPassword = catchAsync(async (req, res, next) => {
  const { email } = req.body;
  if (!email) return next(new AppError('Email is required', 400));

  const code = Math.floor(100000 + Math.random() * 900000).toString();
  const expiry = new Date(Date.now() + 15 * 60000);

  const result = await db.query(
    'UPDATE users SET reset_code = $1, reset_code_expires = $2 WHERE email = $3 RETURNING id',
    [code, expiry, email.toLowerCase().trim()]
  );

  if (result.rows.length === 0) {
    return next(new AppError('No user found with that email address', 404));
  }

  console.log(`[SECURITY] Reset code for ${email}: ${code}`);
  res.status(200).json({ success: true, message: 'Verification code sent' });
});

exports.verifyCode = catchAsync(async (req, res, next) => {
  const { email, code } = req.body;
  const result = await db.query(
    'SELECT * FROM users WHERE email = $1 AND reset_code = $2 AND reset_code_expires > NOW()',
    [email, code]
  );

  if (result.rows.length === 0) {
    return next(new AppError('Invalid or expired code', 400));
  }
  res.status(200).json({ success: true, message: 'Code verified' });
});

exports.resetPassword = catchAsync(async (req, res, next) => {
  const { email, code, password } = req.body;
  if (password.length < 6) return next(new AppError('New password too short', 400));

  const hashedPassword = await bcrypt.hash(password, 12);
  const result = await db.query(
    'UPDATE users SET password = $1, reset_code = NULL, reset_code_expires = NULL WHERE email = $2 AND reset_code = $3 RETURNING id',
    [hashedPassword, email, code]
  );

  if (result.rows.length === 0) {
    return next(new AppError('Reset failed. Code might have expired.', 400));
  }
  res.status(200).json({ success: true, message: 'Password updated' });
});
