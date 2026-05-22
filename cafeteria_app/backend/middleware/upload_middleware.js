const multer = require('multer');
const path = require('path');
const fs = require('fs');
const AppError = require('../utils/app_error');

// Where avatar files live on disk. Served statically from /uploads (see server.js).
const AVATAR_DIR = path.join(__dirname, '..', 'uploads', 'avatars');
fs.mkdirSync(AVATAR_DIR, { recursive: true });

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, AVATAR_DIR),
  filename: (req, file, cb) => {
    // user-<id>-<timestamp>.<ext> — keeps files traceable and avoids collisions.
    const ext = path.extname(file.originalname).toLowerCase() || '.jpg';
    cb(null, `user-${req.user.id}-${Date.now()}${ext}`);
  },
});

const fileFilter = (req, file, cb) => {
  if (file.mimetype.startsWith('image/')) return cb(null, true);
  cb(new AppError('Only image files are allowed', 400));
};

// Single image field named "avatar", capped at 5MB.
const uploadAvatar = multer({
  storage,
  fileFilter,
  limits: { fileSize: 5 * 1024 * 1024 },
}).single('avatar');

module.exports = { uploadAvatar };