const db = require('../config/db');

exports.getMenu = async (req, res) => {
  try {
    const result = await db.query('SELECT * FROM menu_items WHERE is_available = true');
    res.json({ success: true, data: result.rows });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.addItem = async (req, res) => {
  const { name, description, price, image_url, category } = req.body;
  try {
    const result = await db.query(
      'INSERT INTO menu_items (name, description, price, image_url, category) VALUES (\$1, \$2, \$3, \$4, \$5) RETURNING *',
      [name, description, price, image_url, category]
    );
    res.status(201).json({ success: true, data: result.rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.updateItem = async (req, res) => {
  const { id } = req.params;
  const { name, description, price, image_url, category, is_available } = req.body;
  try {
    const result = await db.query(
      'UPDATE menu_items SET name=\$1, description=\$2, price=\$3, image_url=\$4, category=\$5, is_available=\$6 WHERE id=\$7 RETURNING *',
      [name, description, price, image_url, category, is_available, id]
    );
    res.json({ success: true, data: result.rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.deleteItem = async (req, res) => {
  const { id } = req.params;
  try {
    await db.query('DELETE FROM menu_items WHERE id = \$1', [id]);
    res.json({ success: true, message: 'Item deleted' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};
