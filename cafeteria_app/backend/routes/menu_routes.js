const express = require('express');
const router = express.Router();
const menuController = require('../controllers/menu_controller');
const authMiddleware = require('../middleware/auth_middleware');
const roleMiddleware = require('../middleware/role_middleware');

router.get('/', menuController.getMenu);
router.post('/', authMiddleware, roleMiddleware('admin'), menuController.addItem);
router.put('/:id', authMiddleware, roleMiddleware('admin'), menuController.updateItem);
router.delete('/:id', authMiddleware, roleMiddleware('admin'), menuController.deleteItem);

module.exports = router;
