const express = require('express');
const router = express.Router();
const orderController = require('../controllers/order_controller');
const authMiddleware = require('../middleware/auth_middleware');
const roleMiddleware = require('../middleware/role_middleware');

router.post('/', authMiddleware, orderController.placeOrder);
router.get('/my', authMiddleware, orderController.getMyOrders);
router.get('/', authMiddleware, roleMiddleware('admin'), orderController.getAllOrders);
router.patch('/:id/status', authMiddleware, roleMiddleware('admin'), orderController.updateOrderStatus);

module.exports = router;
