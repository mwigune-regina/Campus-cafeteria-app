const db = require('../config/db');
const catchAsync = require('../utils/catch_async');
const AppError = require('../utils/app_error');

exports.getMenu = catchAsync(async (req, res, next) => {
  const result = await db.query('SELECT * FROM menu_items WHERE is_available = true ORDER BY category, name');
  res.status(200).json({
    success: true,
    data: result.rows
  });
});

exports.addItem = catchAsync(async (req, res, next) => {
  const { name, description, price, image_url, category } = req.body;

  if (!name || !price || !category) {
    return next(new AppError('Name, price, and category are required', 400));
  }
  
  if (parseFloat(price) <= 0) {
    return next(new AppError('Price must be a positive number', 400));
  }

  const result = await db.query(
    'INSERT INTO menu_items (name, description, price, image_url, category) VALUES ($1, $2, $3, $4, $5) RETURNING *',
    [name.trim(), description?.trim(), price, image_url, category.trim()]
  );
  
  res.status(201).json({
    success: true,
    data: result.rows[0]
  });
});

exports.searchMenu = catchAsync(async (req, res, next) => {
  const { query } = req.query;
  if (!query) {
    const result = await db.query('SELECT * FROM menu_items WHERE is_available = true ORDER BY category, name');
    return res.status(200).json({ success: true, data: result.rows });
  }

  const result = await db.query(
    "SELECT * FROM menu_items WHERE (name ILIKE $1 OR description ILIKE $1) AND is_available = true",
    [`%${query}%`]
  );
  
  res.status(200).json({
    success: true,
    data: result.rows
  });
});

exports.toggleAvailability = catchAsync(async (req, res, next) => {
  const { id } = req.params;
  const result = await db.query(
    'UPDATE menu_items SET is_available = NOT is_available WHERE id = $1 RETURNING *',
    [id]
  );

  if (result.rows.length === 0) {
    return next(new AppError('No menu item found with that ID', 404));
  }

  res.status(200).json({
    success: true,
    data: result.rows[0]
  });
});

exports.updateItem = catchAsync(async (req, res, next) => {
  const { id } = req.params;
  const { name, description, price, image_url, category, is_available } = req.body;

  const check = await db.query('SELECT * FROM menu_items WHERE id = $1', [id]);
  if (check.rows.length === 0) {
    return next(new AppError('No menu item found with that ID', 404));
  }

  const result = await db.query(
    'UPDATE menu_items SET name=$1, description=$2, price=$3, image_url=$4, category=$5, is_available=$6 WHERE id=$7 RETURNING *',
    [name || check.rows[0].name, description, price || check.rows[0].price, image_url, category, is_available, id]
  );

  res.status(200).json({
    success: true,
    data: result.rows[0]
  });
});

exports.deleteItem = catchAsync(async (req, res, next) => {
  const { id } = req.params;
  const result = await db.query('DELETE FROM menu_items WHERE id = $1 RETURNING *', [id]);
  
  if (result.rows.length === 0) {
    return next(new AppError('No menu item found with that ID', 404));
  }

  res.status(204).json({
    success: true,
    data: null
  });
});
