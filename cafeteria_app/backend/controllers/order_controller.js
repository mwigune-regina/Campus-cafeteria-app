const db = require('../config/db');
const catchAsync = require('../utils/catch_async');
const AppError = require('../utils/app_error');
const crypto = require('crypto');

const ORDER_ITEMS_AGG = `
  COALESCE(
    json_agg(
      json_build_object(
        'menu_item_id', oi.menu_item_id,
        'item_name', mi.name,
        'category', mi.category,
        'image_url', mi.image_url,
        'quantity', oi.quantity,
        'price_at_time', oi.price_at_time
      )
    ) FILTER (WHERE oi.id IS NOT NULL),
    '[]'
  ) AS items
`;

exports.placeOrder = catchAsync(async (req, res, next) => {
  const { items, total_amount } = req.body;
  const userId = req.user.id;

  if (!items || !Array.isArray(items) || items.length === 0) {
    return next(new AppError('Cart cannot be empty', 400));
  }

  try {
    await db.query('BEGIN');

    const userResult = await db.query('SELECT balance FROM users WHERE id = $1', [userId]);
    const currentBalance = parseFloat(userResult.rows[0].balance);

    if (currentBalance < total_amount) {
      throw new AppError('Insufficient wallet balance. Please top up.', 400);
    }

    await db.query('UPDATE users SET balance = balance - $1 WHERE id = $2', [total_amount, userId]);

    const qrCodeToken = crypto.randomBytes(16).toString('hex');

    const orderResult = await db.query(
      'INSERT INTO orders (user_id, total_amount, status, qr_code_token) VALUES ($1, $2, $3, $4) RETURNING id',
      [userId, total_amount, 'paid', qrCodeToken]
    );
    const orderId = orderResult.rows[0].id;

    for (const item of items) {
      const menuResult = await db.query('SELECT price FROM menu_items WHERE id = $1', [item.menuItem.id]);

      if (menuResult.rows.length === 0) {
        throw new AppError(`Item with ID ${item.menuItem.id} not found`, 404);
      }

      const priceAtTime = menuResult.rows[0].price;

      await db.query(
        'INSERT INTO order_items (order_id, menu_item_id, quantity, price_at_time) VALUES ($1, $2, $3, $4)',
        [orderId, item.menuItem.id, item.quantity, priceAtTime]
      );
    }

    await db.query(
      'INSERT INTO wallet_transactions (user_id, amount, type, reference) VALUES ($1, $2, $3, $4)',
      [userId, total_amount, 'payment', `ORDER-${orderId}`]
    );

    await db.query('COMMIT');
    res.status(201).json({
      success: true,
      message: 'Order placed and paid successfully',
      data: {
        orderId,
        qrCodeToken,
        remaining_balance: currentBalance - total_amount
      }
    });
  } catch (err) {
    await db.query('ROLLBACK');
    return next(err);
  }
});

// Cashier: verify QR -> returns full order details (does NOT mark served)
exports.verifyOrderByQR = catchAsync(async (req, res, next) => {
  const { token } = req.body;

  if (!token) {
    return next(new AppError('QR Token is required', 400));
  }

  const result = await db.query(
    `SELECT o.*, u.username, ${ORDER_ITEMS_AGG}
     FROM orders o
     JOIN users u ON o.user_id = u.id
     LEFT JOIN order_items oi ON o.id = oi.order_id
     LEFT JOIN menu_items mi ON oi.menu_item_id = mi.id
     WHERE o.qr_code_token = $1
     GROUP BY o.id, u.username`,
    [token]
  );

  if (result.rows.length === 0) {
    return next(new AppError('Invalid QR Code or Order not found', 404));
  }

  const order = result.rows[0];

  if (order.status === 'served') {
    return next(new AppError('This order has already been served', 400));
  }

  if (order.status === 'cancelled') {
    return next(new AppError('This order was cancelled', 400));
  }

  res.status(200).json({
    success: true,
    data: order
  });
});

exports.getMyOrders = catchAsync(async (req, res, next) => {
  const result = await db.query(
    `SELECT o.*, ${ORDER_ITEMS_AGG}
     FROM orders o
     LEFT JOIN order_items oi ON o.id = oi.order_id
     LEFT JOIN menu_items mi ON oi.menu_item_id = mi.id
     WHERE o.user_id = $1
     GROUP BY o.id
     ORDER BY o.created_at DESC`,
    [req.user.id]
  );

  res.status(200).json({
    success: true,
    data: result.rows
  });
});

// Cashier or admin: all orders
exports.getAllOrders = catchAsync(async (req, res, next) => {
  const { status } = req.query;
  const params = [];
  let where = '';
  if (status) {
    params.push(status);
    where = `WHERE o.status = $${params.length}`;
  }

  const result = await db.query(
    `SELECT o.*, u.username, ${ORDER_ITEMS_AGG}
     FROM orders o
     JOIN users u ON o.user_id = u.id
     LEFT JOIN order_items oi ON o.id = oi.order_id
     LEFT JOIN menu_items mi ON oi.menu_item_id = mi.id
     ${where}
     GROUP BY o.id, u.username
     ORDER BY o.created_at DESC`,
    params
  );

  res.status(200).json({
    success: true,
    data: result.rows
  });
});

// Cashier active queue: paid + preparing + ready
exports.getActiveQueue = catchAsync(async (req, res, next) => {
  const result = await db.query(
    `SELECT o.*, u.username, ${ORDER_ITEMS_AGG}
     FROM orders o
     JOIN users u ON o.user_id = u.id
     LEFT JOIN order_items oi ON o.id = oi.order_id
     LEFT JOIN menu_items mi ON oi.menu_item_id = mi.id
     WHERE o.status IN ('paid', 'preparing', 'ready')
     GROUP BY o.id, u.username
     ORDER BY o.created_at ASC`
  );

  res.status(200).json({
    success: true,
    data: result.rows
  });
});

exports.getOrderById = catchAsync(async (req, res, next) => {
  const { id } = req.params;
  const result = await db.query(
    `SELECT o.*, u.username, ${ORDER_ITEMS_AGG}
     FROM orders o
     JOIN users u ON o.user_id = u.id
     LEFT JOIN order_items oi ON o.id = oi.order_id
     LEFT JOIN menu_items mi ON oi.menu_item_id = mi.id
     WHERE o.id = $1
     GROUP BY o.id, u.username`,
    [id]
  );

  if (result.rows.length === 0) {
    return next(new AppError('Order not found', 404));
  }

  res.status(200).json({
    success: true,
    data: result.rows[0]
  });
});

exports.updateOrderStatus = catchAsync(async (req, res, next) => {
  const { id } = req.params;
  const { status } = req.body;

  const validStatuses = ['pending', 'paid', 'preparing', 'ready', 'served', 'cancelled'];
  if (!validStatuses.includes(status)) {
    return next(new AppError('Invalid status update', 400));
  }

  const result = await db.query(
    'UPDATE orders SET status = $1 WHERE id = $2 RETURNING *',
    [status, id]
  );

  if (result.rows.length === 0) {
    return next(new AppError('Order not found', 404));
  }

  res.status(200).json({
    success: true,
    data: result.rows[0]
  });
});
