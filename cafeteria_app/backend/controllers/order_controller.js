const db = require('../config/db');

exports.placeOrder = async (req, res) => {
  const { items, total_amount } = req.body;
  const userId = req.user.id;
  try {
    const orderResult = await db.query(
      'INSERT INTO orders (user_id, total_amount) VALUES (\$1, \$2) RETURNING id',
      [userId, total_amount]
    );
    const orderId = orderResult.rows[0].id;

    for (const item of items) {
      await db.query(
        'INSERT INTO order_items (order_id, menu_item_id, quantity, price_at_time) VALUES (\$1, \$2, \$3, \$4)',
        [orderId, item.menu_item.id, item.quantity, item.menu_item.price]
      );
    }

    res.status(201).json({ success: true, data: { orderId } });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.getMyOrders = async (req, res) => {
  try {
    const result = await db.query('SELECT * FROM orders WHERE user_id = \$1 ORDER BY created_at DESC', [req.user.id]);
    res.json({ success: true, data: result.rows });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.getAllOrders = async (req, res) => {
  try {
    const result = await db.query('SELECT * FROM orders ORDER BY created_at DESC');
    res.json({ success: true, data: result.rows });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.updateOrderStatus = async (req, res) => {
  const { id } = req.params;
  const { status } = req.body;
  try {
    const result = await db.query('UPDATE orders SET status = \$1 WHERE id = \$2 RETURNING *', [status, id]);
    res.json({ success: true, data: result.rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};
