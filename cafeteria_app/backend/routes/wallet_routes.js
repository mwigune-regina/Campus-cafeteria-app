const express = require('express');
const router = express.Router();
const walletController = require('../controllers/wallet_controller');
const authMiddleware = require('../middleware/auth_middleware');

router.get('/balance', authMiddleware, walletController.getBalance);
router.post('/top-up', authMiddleware, walletController.topUp);
router.get('/transactions', authMiddleware, walletController.getTransactions);

module.exports = router;
