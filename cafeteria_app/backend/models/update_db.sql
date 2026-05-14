-- Idempotent migration to bring any existing cafeteria_db up to current schema.
-- Safe to re-run; uses IF NOT EXISTS / DROP CONSTRAINT IF EXISTS throughout.

-- ----------------------------------------------------------------- users
ALTER TABLE users ADD COLUMN IF NOT EXISTS balance DECIMAL(10, 2) DEFAULT 0.00;
ALTER TABLE users ADD COLUMN IF NOT EXISTS reset_code VARCHAR(6);
ALTER TABLE users ADD COLUMN IF NOT EXISTS reset_code_expires TIMESTAMP;

-- Ensure role constraint allows 'cashier'
ALTER TABLE users DROP CONSTRAINT IF EXISTS users_role_check;
ALTER TABLE users ADD CONSTRAINT users_role_check
    CHECK (role IN ('student', 'cashier', 'admin'));

-- ----------------------------------------------------------------- menu_items
ALTER TABLE menu_items ADD COLUMN IF NOT EXISTS is_available BOOLEAN DEFAULT TRUE;

-- ----------------------------------------------------------------- orders
-- Add qr_code_token column if missing (used by wallet payment flow).
ALTER TABLE orders ADD COLUMN IF NOT EXISTS qr_code_token TEXT;
-- Make sure it's unique (separate to allow IF NOT EXISTS on the column)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'orders_qr_code_token_key'
    ) THEN
        ALTER TABLE orders ADD CONSTRAINT orders_qr_code_token_key UNIQUE (qr_code_token);
    END IF;
END$$;

-- Migrate any legacy 'completed' rows to 'served' so the new constraint accepts them.
UPDATE orders SET status = 'served' WHERE status = 'completed';

-- Replace status constraint with the full set used by the current code.
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_status_check;
ALTER TABLE orders ADD CONSTRAINT orders_status_check
    CHECK (status IN ('pending', 'paid', 'preparing', 'ready', 'served', 'cancelled'));

-- ----------------------------------------------------------------- wallet_transactions
CREATE TABLE IF NOT EXISTS wallet_transactions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    amount DECIMAL(10, 2) NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('topup', 'payment', 'refund')),
    payment_method VARCHAR(50),
    reference VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
