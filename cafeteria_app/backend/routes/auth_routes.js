const express = require('express');
const multer = require('multer');
const router = express.Router();
const authController = require('../controllers/auth_controller');
const authMiddleware = require('../middleware/auth_middleware');
const { uploadAvatar } = require('../middleware/upload_middleware');
const AppError = require('../utils/app_error');

router.post('/register', authController.register);
router.post('/login', authController.login);
router.post('/forgot-password', authController.forgotPassword);
router.post('/verify-code', authController.verifyCode);
router.post('/reset-password', authController.resetPassword);

// Run multer, translating its size/format errors into clean operational AppErrors
// so the global handler returns a useful 400 instead of a generic 500.
const handleAvatarUpload = (req, res, next) => {
  uploadAvatar(req, res, (err) => {
    if (err instanceof multer.MulterError) {
      const msg = err.code === 'LIMIT_FILE_SIZE' ? 'Image must be 5MB or smaller' : err.message;
      return next(new AppError(msg, 400));
    }
    if (err) return next(err);
    next();
  });
};

router.patch('/me', authMiddleware, authController.updateProfile);
router.patch('/me/avatar', authMiddleware, handleAvatarUpload, authController.updateAvatar);

module.exports = router;
