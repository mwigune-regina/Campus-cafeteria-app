/**
 * Seed the cafeteria_db with test users and a starter menu.
 *
 * Run with:    npm run seed
 * Re-run safe: uses ON CONFLICT / NOT EXISTS, so duplicates are ignored.
 *
 * Test accounts created:
 *   admin    / admin123    (manage menu)
 *   cashier  / cashier123  (scan QR, serve orders)
 *   student  / student123  (browse menu, pay) — starts with 25,000 Tsh in wallet
 */
const bcrypt = require('bcryptjs');
const db = require('../config/db');

const USERS = [
  {
    username: 'admin',
    email: 'admin@cafeteria.test',
    password: 'admin123',
    role: 'admin',
    balance: 0,
  },
  {
    username: 'cashier',
    email: 'cashier@cafeteria.test',
    password: 'cashier123',
    role: 'cashier',
    balance: 0,
  },
  {
    username: 'student',
    email: 'student@cafeteria.test',
    password: 'student123',
    role: 'student',
    balance: 25000,
  },
];

const MENU = [
  // Meals
  { name: 'Beef Burger',        category: 'Meals',  price: 5000, description: 'Juicy grilled beef burger with cheese and lettuce.',
    image_url: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=600' },
  { name: 'Rice + Beans',       category: 'Meals',  price: 4500, description: 'Standard portion served with vegetables.',
    image_url: 'https://images.unsplash.com/photo-1574484284002-952d92456975?w=600' },
  { name: 'Chicken Wrap',       category: 'Meals',  price: 6000, description: 'Grilled chicken with veggies in a soft tortilla.',
    image_url: 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=600' },
  { name: 'Pizza Slice',        category: 'Meals',  price: 3500, description: 'Margherita slice, fresh from the oven.',
    image_url: 'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=600' },
  { name: 'Garden Salad',       category: 'Meals',  price: 4000, description: 'Fresh greens, tomatoes, cucumber, and dressing.',
    image_url: 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=600' },
  // Drinks
  { name: 'Soda 350ml',         category: 'Drinks', price: 1000, description: 'Chilled soda — pick your favorite at pickup.',
    image_url: 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?w=600' },
  { name: 'Bottled Water',      category: 'Drinks', price: 500,  description: 'Cool drinking water, 500ml.',
    image_url: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=600' },
  { name: 'Coffee',             category: 'Drinks', price: 2000, description: 'Freshly brewed coffee.',
    image_url: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=600' },
  { name: 'Fresh Juice',        category: 'Drinks', price: 2500, description: 'Seasonal fruit juice, no added sugar.',
    image_url: 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=600' },
];

async function seedUsers() {
  console.log('Seeding users...');
  for (const u of USERS) {
    const hash = await bcrypt.hash(u.password, 12);
    const res = await db.query(
      `INSERT INTO users (username, email, password, role, balance)
       VALUES ($1, $2, $3, $4, $5)
       ON CONFLICT (email) DO NOTHING
       RETURNING id, username, role`,
      [u.username, u.email, hash, u.role, u.balance]
    );
    if (res.rows.length > 0) {
      console.log(`  + ${u.role.padEnd(8)} ${u.username} (${u.email})`);
    } else {
      console.log(`  = ${u.role.padEnd(8)} ${u.username} (already exists)`);
    }
  }
}

async function seedMenu() {
  console.log('Seeding menu...');
  for (const item of MENU) {
    const exists = await db.query('SELECT 1 FROM menu_items WHERE name = $1', [item.name]);
    if (exists.rows.length > 0) {
      console.log(`  = ${item.category.padEnd(7)} ${item.name} (already exists)`);
      continue;
    }
    await db.query(
      `INSERT INTO menu_items (name, description, price, image_url, category, is_available)
       VALUES ($1, $2, $3, $4, $5, TRUE)`,
      [item.name, item.description, item.price, item.image_url, item.category]
    );
    console.log(`  + ${item.category.padEnd(7)} ${item.name}  (Tsh ${item.price})`);
  }
}

(async () => {
  try {
    await seedUsers();
    await seedMenu();
    console.log('\n✓ Seed complete.\n');
    console.log('Test credentials:');
    for (const u of USERS) {
      console.log(`  ${u.role.padEnd(8)} username: ${u.username.padEnd(8)}  password: ${u.password}`);
    }
    process.exit(0);
  } catch (err) {
    console.error('Seed failed:', err.message);
    process.exit(1);
  }
})();
