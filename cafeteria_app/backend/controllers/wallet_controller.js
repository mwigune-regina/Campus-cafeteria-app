const db = require('../config/db');
const catchAsync = require('../utils/catch_async');
const AppError = require('../utils/app_error');

exports.getBalance = catchAsync(async (req, res, next) => {
  const result = await db.query('SELECT balance FROM users WHERE id = $1', [req.user.id]);

  if (result.rows.length === 0) {
    return next(new AppError('User not found', 404));
  }

  res.status(200).json({
    success: true,
    balance: result.rows[0].balance
  });
});

exports.topUp = catchAsync(async (req, res, next) => {
  const { amount, payment_method } = req.body;

  if (!amount || amount <= 0) {
    return next(new AppError('Please provide a valid top-up amount', 400));
  }

  try {
    await db.query('BEGIN');

    const result = await db.query(
      'UPDATE users SET balance = balance + $1 WHERE id = $2 RETURNING balance',
      [amount, req.user.id]
    );

    const reference = `TXN-${Date.now()}`;
    const tx = await db.query(
      `INSERT INTO wallet_transactions (user_id, amount, type, payment_method, reference)
       VALUES ($1, $2, 'topup', $3, $4)
       RETURNING id, reference, created_at`,
      [req.user.id, amount, payment_method || 'M-Pesa', reference]
    );

    await db.query('COMMIT');

    res.status(200).json({
      success: true,
      message: 'Top-up successful',
      data: {
        new_balance: result.rows[0].balance,
        transaction_id: tx.rows[0].reference,
        payment_method: payment_method || 'M-Pesa',
        created_at: tx.rows[0].created_at
      }
    });
  } catch (err) {
    await db.query('ROLLBACK');
    return next(err);
  }
});

exports.getTransactions = catchAsync(async (req, res, next) => {
  const result = await db.query(
    `SELECT id, amount, type, payment_method, reference, created_at
     FROM wallet_transactions
     WHERE user_id = $1
     ORDER BY created_at DESC
     LIMIT 50`,
    [req.user.id]
  );

  res.status(200).json({
    success: true,
    data: result.rows
  });
});
