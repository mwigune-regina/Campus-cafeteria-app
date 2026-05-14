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
      user: { id: user.id, username: user.username, email: user.email, role: user.role }
    }
  });
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
