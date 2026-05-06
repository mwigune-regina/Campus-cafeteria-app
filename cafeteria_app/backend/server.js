const express = require('express');
const cors = require('cors');
require('dotenv').config();

const authRoutes = require('./routes/auth_routes');
const menuRoutes = require('./routes/menu_routes');
const orderRoutes = require('./routes/order_routes');

const app = express();

app.use(cors());
app.use(express.json());

app.use('/api/auth', authRoutes);
app.use('/api/menu', menuRoutes);
app.use('/api/orders', orderRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port \${PORT}`);
});
