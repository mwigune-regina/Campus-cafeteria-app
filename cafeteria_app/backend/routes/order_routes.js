const express = require('express');
const router = express.Router();
const orderController = require('../controllers/order_controller');
const authMiddleware = require('../middleware/auth_middleware');
const roleMiddleware = require('../middleware/role_middleware');

// Student
router.post('/', authMiddleware, orderController.placeOrder);
router.get('/my', authMiddleware, orderController.getMyOrders);

// Cashier + admin
router.get('/', authMiddleware, roleMiddleware(['cashier', 'admin']), orderController.getAllOrders);
router.get('/queue', authMiddleware, roleMiddleware(['cashier', 'admin']), orderController.getActiveQueue);
router.post('/verify-qr', authMiddleware, roleMiddleware(['cashier', 'admin']), orderController.verifyOrderByQR);
router.patch('/:id/status', authMiddleware, roleMiddleware(['cashier', 'admin']), orderController.updateOrderStatus);

// Order by id - student can see their own, cashier/admin can see any
router.get('/:id', authMiddleware, orderController.getOrderById);

module.exports = router;
