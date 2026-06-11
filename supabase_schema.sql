-- ============================================================
-- Darzi Pro — Supabase Database Schema
-- Run this in your Supabase SQL Editor to set up the database
-- ============================================================

-- 1. Shops table (created manually by admin)
CREATE TABLE IF NOT EXISTS shops (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  owner_name TEXT NOT NULL,
  phone TEXT NOT NULL,
  language TEXT DEFAULT 'en',
  currency TEXT DEFAULT 'PKR',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Customers table
CREATE TABLE IF NOT EXISTS customers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id UUID REFERENCES shops(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  address TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  is_deleted BOOLEAN DEFAULT false
);

-- 3. Orders table
CREATE TABLE IF NOT EXISTS orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id UUID REFERENCES shops(id) ON DELETE CASCADE,
  customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
  order_number TEXT NOT NULL,
  garment_type TEXT NOT NULL,
  order_date DATE NOT NULL,
  delivery_date DATE NOT NULL,
  is_urgent BOOLEAN DEFAULT false,
  status TEXT DEFAULT 'pending',
  total_amount DECIMAL(10,2) NOT NULL,
  advance_paid DECIMAL(10,2) DEFAULT 0,
  balance_paid BOOLEAN DEFAULT false,
  fabric_notes TEXT,
  order_notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  is_deleted BOOLEAN DEFAULT false
);

-- 4. Measurements table (per order)
CREATE TABLE IF NOT EXISTS measurements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  shop_id UUID REFERENCES shops(id) ON DELETE CASCADE,
  kameez_length DECIMAL(5,1),
  sleeve DECIMAL(5,1),
  shoulder DECIMAL(5,1),
  neck DECIMAL(5,1),
  hem DECIMAL(5,1),
  chest DECIMAL(5,1),
  waist DECIMAL(5,1),
  shalwar_length DECIMAL(5,1),
  leg_opening DECIMAL(5,1),
  cuff DECIMAL(5,1),
  fit_notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 5. Style preferences table (per order)
CREATE TABLE IF NOT EXISTS style_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
  shop_id UUID REFERENCES shops(id) ON DELETE CASCADE,
  collar TEXT,
  pockets text[],
  daman TEXT,
  cuffs TEXT,
  silk_thread BOOLEAN DEFAULT false,
  stitching TEXT,
  buttons TEXT,
  suit_style text[],
  shalwar_style TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- Row Level Security (RLS)
-- Each shop only sees their own data via shop_id
-- ============================================================

ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE measurements ENABLE ROW LEVEL SECURITY;
ALTER TABLE style_preferences ENABLE ROW LEVEL SECURITY;

-- Policy: shop isolation for customers
CREATE POLICY "shop_isolation_customers" ON customers
  FOR ALL USING (
    shop_id = (
      SELECT (raw_user_meta_data->>'shop_id')::UUID 
      FROM auth.users 
      WHERE id = auth.uid()
    )
  );

-- Policy: shop isolation for orders
CREATE POLICY "shop_isolation_orders" ON orders
  FOR ALL USING (
    shop_id = (
      SELECT (raw_user_meta_data->>'shop_id')::UUID 
      FROM auth.users 
      WHERE id = auth.uid()
    )
  );

-- Policy: shop isolation for measurements
CREATE POLICY "shop_isolation_measurements" ON measurements
  FOR ALL USING (
    shop_id = (
      SELECT (raw_user_meta_data->>'shop_id')::UUID 
      FROM auth.users 
      WHERE id = auth.uid()
    )
  );

-- Policy: shop isolation for style_preferences
CREATE POLICY "shop_isolation_style_preferences" ON style_preferences
  FOR ALL USING (
    shop_id = (
      SELECT (raw_user_meta_data->>'shop_id')::UUID 
      FROM auth.users 
      WHERE id = auth.uid()
    )
  );

-- ============================================================
-- Indexes for performance
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_customers_shop_id ON customers(shop_id);
CREATE INDEX IF NOT EXISTS idx_customers_updated_at ON customers(updated_at);
CREATE INDEX IF NOT EXISTS idx_orders_shop_id ON orders(shop_id);
CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_updated_at ON orders(updated_at);
CREATE INDEX IF NOT EXISTS idx_measurements_order_id ON measurements(order_id);
CREATE INDEX IF NOT EXISTS idx_style_preferences_order_id ON style_preferences(order_id);

-- ============================================================
-- Helper: auto-update updated_at on row changes
-- ============================================================

CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER customers_updated_at
  BEFORE UPDATE ON customers
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER orders_updated_at
  BEFORE UPDATE ON orders
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER measurements_updated_at
  BEFORE UPDATE ON measurements
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER style_preferences_updated_at
  BEFORE UPDATE ON style_preferences
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
