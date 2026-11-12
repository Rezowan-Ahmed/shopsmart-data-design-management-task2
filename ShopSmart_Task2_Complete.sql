-- SHOPSMART ONLINE LTD. | TASK 2 | COMPLETE SQL APPENDIX
-- PostgreSQL 18 / pgAdmin 4 | SYNTHETIC academic practice dataset
-- RUN IN A BRAND-NEW EMPTY DATABASE, for example: shopsmart_task2_github_test
-- IMPORTANT: DO NOT run against the existing shopsmart_db or replay database.
-- This script does not contain CREATE DATABASE; create/select the empty database
-- first in pgAdmin 4, then execute this entire file once (F5 with none selected).
-- Original student-uploaded 9-table schema/insertion, constraints, monthly view;
-- five analyses, reconciliation, inventory view recovered from slide speaker notes.
-- Only this introductory comment header was adapted for clean-run distribution.
-- The source SQL statements and original section comments are unchanged.
-- Outputs from multiple SELECTs are most easily reviewed by running sections.
-- FULL CLEAN-RUN SUCCESS AND ACTUAL RESULT VALUES MUST BE TESTED IN POSTGRESQL.
-- NB: Formula-based stock calculation may report 24 reorder alerts, NOT 17;
-- confirm with the PostgreSQL checks supplied in README / verification file.

-- ========================================================================================
-- SECTION 01 / 10  01_Database_Creation_and_Synthetic_Inserts.sql
-- Source: Uploaded original source · Tables, 780 synthetic records and count check
-- ========================================================================================

-- SHOPSMART ONLINE LTD | TASK 2 PRACTICAL DATABASE + SYNTHETIC DATA
-- PostgreSQL 18 / pgAdmin 4 | prepared 15 October 2026
-- Contents: 9 linked tables, with 30 or more synthetic rows in EACH table.
-- All names, suppliers, products, emails and transactions are fictional examples.
-- Uses example.com (reserved for examples); no real personal information.
-- Safe to rerun: CREATE TABLE IF NOT EXISTS and ON CONFLICT DO NOTHING.
-- Existing customers table from your first practice exercise is preserved.
-- DO NOT run this in the default 'postgres' database: select shopsmart_db.

BEGIN;

-- A. TABLES: CUSTOMER + CATEGORY + SUPPLIER + EMPLOYEE
CREATE TABLE IF NOT EXISTS customers (
    customer_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    city VARCHAR(100),
    registration_date DATE DEFAULT CURRENT_DATE
);

CREATE TABLE IF NOT EXISTS categories (
    category_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_name VARCHAR(90) NOT NULL UNIQUE,
    description VARCHAR(200)
);

CREATE TABLE IF NOT EXISTS suppliers (
    supplier_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    supplier_code VARCHAR(12) NOT NULL UNIQUE,
    supplier_name VARCHAR(120) NOT NULL,
    contact_email VARCHAR(150) NOT NULL UNIQUE,
    city VARCHAR(80) NOT NULL,
    lead_time_days INTEGER NOT NULL CHECK (lead_time_days BETWEEN 1 AND 60)
);

CREATE TABLE IF NOT EXISTS employees (
    employee_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    work_email VARCHAR(150) NOT NULL UNIQUE,
    department VARCHAR(60) NOT NULL,
    hire_date DATE NOT NULL
);

-- B. LINKED BUSINESS TABLES
CREATE TABLE IF NOT EXISTS products (
    product_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sku VARCHAR(20) NOT NULL UNIQUE,
    product_name VARCHAR(120) NOT NULL,
    category_id INTEGER NOT NULL REFERENCES categories(category_id),
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price > 0),
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS inventory (
    inventory_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id INTEGER NOT NULL UNIQUE REFERENCES products(product_id),
    supplier_id INTEGER NOT NULL REFERENCES suppliers(supplier_id),
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0),
    reorder_level INTEGER NOT NULL CHECK (reorder_level >= 0),
    last_restocked DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS orders (
    order_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_reference VARCHAR(25) NOT NULL UNIQUE,
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id),
    handled_by_employee_id INTEGER NOT NULL REFERENCES employees(employee_id),
    order_date TIMESTAMP NOT NULL,
    order_status VARCHAR(20) NOT NULL
        CHECK (order_status IN ('Processing', 'Shipped', 'Completed'))
);

CREATE TABLE IF NOT EXISTS order_items (
    order_item_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id INTEGER NOT NULL REFERENCES orders(order_id),
    product_id INTEGER NOT NULL REFERENCES products(product_id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price > 0),
    CONSTRAINT uq_order_product UNIQUE (order_id, product_id)
);

CREATE TABLE IF NOT EXISTS payments (
    payment_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id INTEGER NOT NULL UNIQUE REFERENCES orders(order_id),
    payment_date TIMESTAMP NOT NULL,
    amount NUMERIC(12,2) NOT NULL CHECK (amount > 0),
    payment_method VARCHAR(25) NOT NULL
        CHECK (payment_method IN ('Card', 'PayPal', 'Apple Pay', 'Bank Transfer')),
    payment_status VARCHAR(20) NOT NULL DEFAULT 'Paid'
        CHECK (payment_status IN ('Paid', 'Pending', 'Refunded'))
);

-- C. INSERT 30 CUSTOMERS (reuses the original 20 if you added them earlier)
INSERT INTO customers (first_name, last_name, email, city, registration_date)
VALUES
    ('Olivia', 'Smith', 'olivia.smith@example.com', 'London', '2025-01-15'),
    ('James', 'Wilson', 'james.wilson@example.com', 'Manchester', '2025-02-10'),
    ('Sophia', 'Brown', 'sophia.brown@example.com', 'Birmingham', '2025-03-05'),
    ('Noah', 'Taylor', 'noah.taylor@example.com', 'Leeds', '2025-03-22'),
    ('Amelia', 'Davies', 'amelia.davies@example.com', 'Bristol', '2025-04-12'),
    ('Oliver', 'Evans', 'oliver.evans@example.com', 'Liverpool', '2025-05-08'),
    ('Isla', 'Thomas', 'isla.thomas@example.com', 'Sheffield', '2025-05-25'),
    ('George', 'Roberts', 'george.roberts@example.com', 'Nottingham', '2025-06-14'),
    ('Ava', 'Johnson', 'ava.johnson@example.com', 'Leicester', '2025-07-03'),
    ('Harry', 'Walker', 'harry.walker@example.com', 'Cardiff', '2025-07-19'),
    ('Mia', 'Wright', 'mia.wright@example.com', 'Newcastle', '2025-08-10'),
    ('Jack', 'Thompson', 'jack.thompson@example.com', 'Oxford', '2025-09-06'),
    ('Lily', 'White', 'lily.white@example.com', 'Cambridge', '2025-09-28'),
    ('Charlie', 'Harris', 'charlie.harris@example.com', 'Southampton', '2025-10-11'),
    ('Grace', 'Martin', 'grace.martin@example.com', 'Brighton', '2025-11-04'),
    ('Leo', 'Clark', 'leo.clark@example.com', 'York', '2025-11-22'),
    ('Freya', 'Lewis', 'freya.lewis@example.com', 'Coventry', '2025-12-09'),
    ('Oscar', 'Hall', 'oscar.hall@example.com', 'Reading', '2026-01-16'),
    ('Emily', 'Allen', 'emily.allen@example.com', 'Edinburgh', '2026-02-07'),
    ('Henry', 'Young', 'henry.young@example.com', 'Glasgow', '2026-03-18'),
    ('Aisha', 'Patel', 'aisha.patel@example.com', 'London', '2025-08-21'),
    ('Muhammad', 'Khan', 'muhammad.khan@example.com', 'Bradford', '2025-10-18'),
    ('Charlotte', 'Bennett', 'charlotte.bennett@example.com', 'Norwich', '2026-01-12'),
    ('Daniel', 'Murphy', 'daniel.murphy@example.com', 'Belfast', '2026-02-24'),
    ('Zara', 'Ahmed', 'zara.ahmed@example.com', 'Derby', '2026-03-14'),
    ('Ethan', 'Collins', 'ethan.collins@example.com', 'Plymouth', '2026-04-09'),
    ('Ruby', 'Morgan', 'ruby.morgan@example.com', 'Swansea', '2026-05-02'),
    ('Isaac', 'Cooper', 'isaac.cooper@example.com', 'Portsmouth', '2026-05-27'),
    ('Priya', 'Shah', 'priya.shah@example.com', 'Milton Keynes', '2026-06-19'),
    ('Thomas', 'Reed', 'thomas.reed@example.com', 'Bath', '2026-07-04')
ON CONFLICT (email) DO NOTHING;
-- D. INSERT 30 CATEGORIES
INSERT INTO categories (category_name, description)
VALUES
    ('Laptops & Tablets', 'Computers and portable devices'),
    ('Mobile Accessories', 'Phone charging and everyday accessories'),
    ('Headphones & Audio', 'Personal and wireless audio devices'),
    ('Computer Accessories', 'Keyboards, mice and accessories'),
    ('Home Office', 'Home working products'),
    ('Gaming Accessories', 'Gaming controllers and peripherals'),
    ('TV & Home Cinema', 'Home entertainment devices'),
    ('Smart Home', 'Connected home equipment'),
    ('Kitchen Appliances', 'Small kitchen electrical products'),
    ('Coffee & Tea', 'Coffee and tea preparation accessories'),
    ('Cookware', 'Pans and cookware sets'),
    ('Dining & Tableware', 'Dinnerware and cutlery'),
    ('Bedding', 'Bedding and pillows'),
    ('Bath & Towels', 'Bathroom accessories and towels'),
    ('Cleaning & Laundry', 'Household cleaning products'),
    ('Home Storage', 'Household organisers and storage'),
    ('Lighting & Decor', 'Home decorative items'),
    ('Mens Clothing', 'Casual menswear'),
    ('Womens Clothing', 'Casual womenswear'),
    ('Footwear', 'Everyday footwear'),
    ('Bags & Luggage', 'Bags and travel accessories'),
    ('Beauty & Skincare', 'Skincare essentials'),
    ('Personal Care', 'Personal grooming devices'),
    ('Fitness & Exercise', 'Home fitness products'),
    ('Outdoor & Camping', 'Outdoor activity essentials'),
    ('Cycling Accessories', 'Everyday cycling products'),
    ('Toys & Games', 'Games and educational toys'),
    ('Books & Stationery', 'Stationery and paper goods'),
    ('Pet Supplies', 'Everyday pet-care accessories'),
    ('Garden & DIY', 'DIY equipment and garden essentials')
ON CONFLICT (category_name) DO NOTHING;
-- E. INSERT 30 SUPPLIERS (fictional companies)
INSERT INTO suppliers (supplier_code, supplier_name, contact_email, city, lead_time_days)
VALUES
    ('SUP-01', 'Northbridge Tech Wholesale', 'orders01@suppliers.example.com', 'Leeds', 5),
    ('SUP-02', 'Thames Mobile Distribution', 'orders02@suppliers.example.com', 'London', 8),
    ('SUP-03', 'SoundWave Trade Supplies', 'orders03@suppliers.example.com', 'Manchester', 11),
    ('SUP-04', 'ByteCraft Distribution', 'orders04@suppliers.example.com', 'Birmingham', 14),
    ('SUP-05', 'Deskwise Office Supply', 'orders05@suppliers.example.com', 'Bristol', 17),
    ('SUP-06', 'PlayGear Trade', 'orders06@suppliers.example.com', 'Nottingham', 3),
    ('SUP-07', 'HomeScreen Wholesale', 'orders07@suppliers.example.com', 'Milton Keynes', 6),
    ('SUP-08', 'Connected Living Supply', 'orders08@suppliers.example.com', 'Reading', 9),
    ('SUP-09', 'Kitchenline Distribution', 'orders09@suppliers.example.com', 'Leicester', 12),
    ('SUP-10', 'BrewCraft Wholesale', 'orders10@suppliers.example.com', 'York', 15),
    ('SUP-11', 'PantryPro Trading', 'orders11@suppliers.example.com', 'Sheffield', 18),
    ('SUP-12', 'Table & Home Supply', 'orders12@suppliers.example.com', 'Liverpool', 4),
    ('SUP-13', 'SoftNest Textiles', 'orders13@suppliers.example.com', 'Bradford', 7),
    ('SUP-14', 'FreshBath Wholesale', 'orders14@suppliers.example.com', 'Cardiff', 10),
    ('SUP-15', 'CleanChoice Distributors', 'orders15@suppliers.example.com', 'Coventry', 13),
    ('SUP-16', 'Spacewise Storage Trade', 'orders16@suppliers.example.com', 'Derby', 16),
    ('SUP-17', 'BrightHome Distribution', 'orders17@suppliers.example.com', 'Norwich', 2),
    ('SUP-18', 'Everyday Menswear Trade', 'orders18@suppliers.example.com', 'Manchester', 5),
    ('SUP-19', 'Studio Womenswear Supply', 'orders19@suppliers.example.com', 'London', 8),
    ('SUP-20', 'StepRight Footwear Trade', 'orders20@suppliers.example.com', 'Leeds', 11),
    ('SUP-21', 'UrbanCarry Distribution', 'orders21@suppliers.example.com', 'Bristol', 14),
    ('SUP-22', 'PureCare Wholesale', 'orders22@suppliers.example.com', 'Oxford', 17),
    ('SUP-23', 'DailyGroom Supplies', 'orders23@suppliers.example.com', 'Newcastle', 3),
    ('SUP-24', 'MoveMore Fitness Trade', 'orders24@suppliers.example.com', 'Birmingham', 6),
    ('SUP-25', 'Trailready Equipment', 'orders25@suppliers.example.com', 'Southampton', 9),
    ('SUP-26', 'Cyclewise Wholesale', 'orders26@suppliers.example.com', 'Cambridge', 12),
    ('SUP-27', 'BrightPlay Trading', 'orders27@suppliers.example.com', 'Leicester', 15),
    ('SUP-28', 'PaperTrail Office Goods', 'orders28@suppliers.example.com', 'Glasgow', 18),
    ('SUP-29', 'HappyPaws Distribution', 'orders29@suppliers.example.com', 'Edinburgh', 4),
    ('SUP-30', 'GreenFix Hardware Trade', 'orders30@suppliers.example.com', 'Plymouth', 7)
ON CONFLICT (supplier_code) DO NOTHING;
-- F. INSERT 30 EMPLOYEES
INSERT INTO employees (first_name, last_name, work_email, department, hire_date)
VALUES
    ('Emma', 'Parker', 'emma.parker@staff.example.com', 'Warehouse', '2023-03-13'),
    ('Liam', 'Mitchell', 'liam.mitchell@staff.example.com', 'Customer Service', '2023-04-11'),
    ('Sofia', 'Turner', 'sofia.turner@staff.example.com', 'Operations', '2023-05-08'),
    ('Jacob', 'Phillips', 'jacob.phillips@staff.example.com', 'Marketing', '2023-06-01'),
    ('Maya', 'Campbell', 'maya.campbell@staff.example.com', 'Finance', '2023-07-17'),
    ('Benjamin', 'Scott', 'benjamin.scott@staff.example.com', 'IT', '2023-08-03'),
    ('Fatima', 'Hussain', 'fatima.hussain@staff.example.com', 'Procurement', '2023-09-25'),
    ('Lucas', 'Edwards', 'lucas.edwards@staff.example.com', 'Analytics', '2023-10-09'),
    ('Ella', 'Price', 'ella.price@staff.example.com', 'Warehouse', '2023-11-14'),
    ('Adam', 'Russell', 'adam.russell@staff.example.com', 'Customer Service', '2024-01-15'),
    ('Nadia', 'Ali', 'nadia.ali@staff.example.com', 'Operations', '2024-02-06'),
    ('William', 'Foster', 'william.foster@staff.example.com', 'Marketing', '2024-03-12'),
    ('Hannah', 'Bell', 'hannah.bell@staff.example.com', 'Finance', '2024-04-18'),
    ('Joshua', 'Howard', 'joshua.howard@staff.example.com', 'IT', '2024-05-07'),
    ('Sana', 'Iqbal', 'sana.iqbal@staff.example.com', 'Procurement', '2024-06-24'),
    ('Alexander', 'Ward', 'alexander.ward@staff.example.com', 'Analytics', '2024-07-04'),
    ('Chloe', 'Brooks', 'chloe.brooks@staff.example.com', 'Warehouse', '2024-08-21'),
    ('Elliot', 'Wood', 'elliot.wood@staff.example.com', 'Customer Service', '2024-09-16'),
    ('Leila', 'Rahman', 'leila.rahman@staff.example.com', 'Operations', '2024-10-11'),
    ('Samuel', 'Bailey', 'samuel.bailey@staff.example.com', 'Marketing', '2024-11-05'),
    ('Jessica', 'Ford', 'jessica.ford@staff.example.com', 'Finance', '2025-01-14'),
    ('Omar', 'Malik', 'omar.malik@staff.example.com', 'IT', '2025-02-10'),
    ('Harriet', 'Cole', 'harriet.cole@staff.example.com', 'Procurement', '2025-03-17'),
    ('Finn', 'Gray', 'finn.gray@staff.example.com', 'Analytics', '2025-04-22'),
    ('Poppy', 'Kelly', 'poppy.kelly@staff.example.com', 'Warehouse', '2025-05-19'),
    ('Aaron', 'Baker', 'aaron.baker@staff.example.com', 'Customer Service', '2025-06-27'),
    ('Imani', 'Green', 'imani.green@staff.example.com', 'Operations', '2025-07-16'),
    ('Dylan', 'Morris', 'dylan.morris@staff.example.com', 'Marketing', '2025-08-14'),
    ('Rose', 'Hughes', 'rose.hughes@staff.example.com', 'Finance', '2025-09-23'),
    ('Nathan', 'Powell', 'nathan.powell@staff.example.com', 'IT', '2025-10-20')
ON CONFLICT (work_email) DO NOTHING;
-- G. INSERT 60 PRODUCTS (2 realistic products per category)
-- Category foreign keys are obtained from the matching category names.
WITH source (sku, product_name, category_name, unit_price) AS (
    VALUES
    ('SS-001', '13-inch Student Laptop', 'Laptops & Tablets', '649.00'),
    ('SS-002', '10-inch Wi-Fi Tablet', 'Laptops & Tablets', '229.00'),
    ('SS-003', '20W USB-C Wall Charger', 'Mobile Accessories', '19.99'),
    ('SS-004', '10000mAh Power Bank', 'Mobile Accessories', '29.99'),
    ('SS-005', 'Wireless In-Ear Earbuds', 'Headphones & Audio', '49.99'),
    ('SS-006', 'Portable Bluetooth Speaker', 'Headphones & Audio', '59.99'),
    ('SS-007', 'Ergonomic Wireless Mouse', 'Computer Accessories', '17.99'),
    ('SS-008', 'Compact Mechanical Keyboard', 'Computer Accessories', '69.99'),
    ('SS-009', 'Adjustable LED Desk Lamp', 'Home Office', '32.50'),
    ('SS-010', 'Aluminium Laptop Stand', 'Home Office', '28.99'),
    ('SS-011', 'Stereo Gaming Headset', 'Gaming Accessories', '39.99'),
    ('SS-012', 'Wireless Game Controller', 'Gaming Accessories', '44.99'),
    ('SS-013', '4K Media Streaming Stick', 'TV & Home Cinema', '38.99'),
    ('SS-014', 'Compact TV Soundbar', 'TV & Home Cinema', '139.00'),
    ('SS-015', 'Smart LED Bulb Twin Pack', 'Smart Home', '24.99'),
    ('SS-016', 'Wi-Fi Smart Plug', 'Smart Home', '14.99'),
    ('SS-017', '4-Litre Digital Air Fryer', 'Kitchen Appliances', '89.00'),
    ('SS-018', '1.7-Litre Electric Kettle', 'Kitchen Appliances', '26.99'),
    ('SS-019', 'Glass Coffee Cafetiere', 'Coffee & Tea', '19.50'),
    ('SS-020', 'Rechargeable Milk Frother', 'Coffee & Tea', '21.99'),
    ('SS-021', '28cm Non-Stick Frying Pan', 'Cookware', '24.00'),
    ('SS-022', 'Three-Piece Saucepan Set', 'Cookware', '67.50'),
    ('SS-023', 'Stoneware Dinner Plate Set', 'Dining & Tableware', '44.99'),
    ('SS-024', '24-Piece Cutlery Set', 'Dining & Tableware', '31.50'),
    ('SS-025', 'Cotton Double Duvet Set', 'Bedding', '37.00'),
    ('SS-026', 'Memory Foam Pillow', 'Bedding', '29.50'),
    ('SS-027', 'Large Cotton Bath Towel', 'Bath & Towels', '15.99'),
    ('SS-028', 'Non-Slip Shower Mat', 'Bath & Towels', '12.99'),
    ('SS-029', 'Lightweight Steam Mop', 'Cleaning & Laundry', '72.00'),
    ('SS-030', 'Collapsible Laundry Basket', 'Cleaning & Laundry', '17.50'),
    ('SS-031', 'Stackable Storage Boxes 3-Pack', 'Home Storage', '24.50'),
    ('SS-032', 'Four-Tier Shoe Rack', 'Home Storage', '34.00'),
    ('SS-033', 'Adjustable Floor Lamp', 'Lighting & Decor', '59.00'),
    ('SS-034', 'Round Wall Mirror', 'Lighting & Decor', '49.00'),
    ('SS-035', 'Classic Cotton Polo Shirt', 'Mens Clothing', '22.99'),
    ('SS-036', 'Unisex Fleece Hoodie', 'Mens Clothing', '36.00'),
    ('SS-037', 'Relaxed Linen Shirt', 'Womens Clothing', '29.99'),
    ('SS-038', 'Knitted Everyday Cardigan', 'Womens Clothing', '39.00'),
    ('SS-039', 'Cushioned Running Trainers', 'Footwear', '64.00'),
    ('SS-040', 'Water-Resistant Ankle Boots', 'Footwear', '69.00'),
    ('SS-041', 'Commuter Laptop Backpack', 'Bags & Luggage', '42.00'),
    ('SS-042', 'Cabin-Size Spinner Suitcase', 'Bags & Luggage', '89.00'),
    ('SS-043', 'Daily Facial Moisturiser', 'Beauty & Skincare', '14.00'),
    ('SS-044', 'SPF 50 Face Sunscreen', 'Beauty & Skincare', '16.00'),
    ('SS-045', 'Rechargeable Electric Toothbrush', 'Personal Care', '48.00'),
    ('SS-046', 'Compact Ionic Hair Dryer', 'Personal Care', '37.00'),
    ('SS-047', 'Non-Slip Yoga Mat', 'Fitness & Exercise', '20.00'),
    ('SS-048', 'Resistance Band Set', 'Fitness & Exercise', '17.00'),
    ('SS-049', 'Rechargeable Camping Lantern', 'Outdoor & Camping', '26.00'),
    ('SS-050', 'Insulated Thermal Flask', 'Outdoor & Camping', '19.00'),
    ('SS-051', 'Combination Bicycle Lock', 'Cycling Accessories', '21.00'),
    ('SS-052', 'USB Bike Light Set', 'Cycling Accessories', '25.00'),
    ('SS-053', 'Wooden Animal Puzzle', 'Toys & Games', '18.00'),
    ('SS-054', 'Family Strategy Board Game', 'Toys & Games', '27.00'),
    ('SS-055', 'A5 Ruled Notebook Set', 'Books & Stationery', '12.00'),
    ('SS-056', 'Undated Weekly Planner', 'Books & Stationery', '15.00'),
    ('SS-057', 'Adjustable Dog Lead', 'Pet Supplies', '14.00'),
    ('SS-058', 'Corrugated Cat Scratch Mat', 'Pet Supplies', '21.00'),
    ('SS-059', '12V Cordless Drill Set', 'Garden & DIY', '89.00'),
    ('SS-060', 'Reusable Garden Gloves', 'Garden & DIY', '12.00'))
INSERT INTO products (sku, product_name, category_id, unit_price)
SELECT source.sku, source.product_name, c.category_id, source.unit_price::NUMERIC(10,2)
FROM source
JOIN categories c ON c.category_name = source.category_name
WHERE TRUE
ON CONFLICT (sku) DO NOTHING;

-- H. INSERT 60 INVENTORY RECORDS (1 per product)
-- Each supplier is connected to two products. Some items deliberately fall
-- below reorder level to make the low-stock business query meaningful.
WITH product_numbers AS (
    SELECT p.product_id, p.sku, p.unit_price,
           SUBSTRING(p.sku FROM 4)::INTEGER AS n
    FROM products p
    WHERE p.sku LIKE 'SS-%'
)
INSERT INTO inventory
    (product_id, supplier_id, stock_quantity, reorder_level, last_restocked)
SELECT p.product_id, s.supplier_id,
       CASE WHEN p.n % 9 = 0 THEN 2
            WHEN p.n % 7 = 0 THEN 4
            WHEN p.n % 5 = 0 THEN 6
            ELSE 14 + ((p.n * 11) % 92) END AS stock_quantity,
       CASE WHEN p.unit_price >= 100 THEN 8 ELSE 12 END AS reorder_level,
       DATE '2026-09-01' + ((p.n * 3) % 43) AS last_restocked
FROM product_numbers p
JOIN suppliers s ON s.supplier_code =
    ('SUP-' || LPAD(((p.n + 1) / 2)::TEXT, 2, '0'))
WHERE TRUE
ON CONFLICT (product_id) DO NOTHING;

-- I. INSERT 120 ORDERS OVER AUGUST-OCTOBER 2026
-- Each order is allocated to one seeded customer and one employee.
WITH customer_pool AS (
    SELECT customer_id, ROW_NUMBER() OVER (ORDER BY email) AS rn
    FROM customers WHERE email LIKE '%@example.com'
),
employee_pool AS (
    SELECT employee_id, ROW_NUMBER() OVER (ORDER BY work_email) AS rn
    FROM employees WHERE work_email LIKE '%@staff.example.com'
),
order_numbers AS (
    SELECT n FROM GENERATE_SERIES(1, 120) AS gs(n)
)
INSERT INTO orders
    (order_reference, customer_id, handled_by_employee_id, order_date, order_status)
SELECT 'SS-ORD-2026-' || LPAD(o.n::TEXT, 4, '0'),
       c.customer_id,
       e.employee_id,
       TIMESTAMP '2026-08-01 09:00:00'
         + (((o.n * 37) % 75) * INTERVAL '1 day')
         + (((o.n * 71) % 600) * INTERVAL '1 minute'),
       CASE WHEN o.n % 13 = 0 THEN 'Processing'
            WHEN o.n % 4 = 0 THEN 'Shipped'
            ELSE 'Completed' END
FROM order_numbers o
JOIN customer_pool c ON c.rn = ((o.n - 1) % 30) + 1
JOIN employee_pool e ON e.rn = ((o.n * 7 - 1) % 30) + 1
WHERE TRUE
ON CONFLICT (order_reference) DO NOTHING;

-- J. INSERT 300 ORDER ITEMS (alternating two and three products per order)
-- Price is copied from the product price at sale time.
INSERT INTO order_items (order_id, product_id, quantity, unit_price)
SELECT o.order_id,
       p.product_id,
       1 + ((ref.n + item.line_number) % 4),
       p.unit_price
FROM orders o
CROSS JOIN LATERAL
    (SELECT RIGHT(o.order_reference, 4)::INTEGER AS n) ref
CROSS JOIN LATERAL
    GENERATE_SERIES(1, 2 + (ref.n % 2)) AS item(line_number)
JOIN products p ON p.sku =
    ('SS-' || LPAD((((ref.n * 7 + item.line_number * 13) % 60) + 1)::TEXT, 3, '0'))
WHERE o.order_reference LIKE 'SS-ORD-2026-%'
ON CONFLICT (order_id, product_id) DO NOTHING;

-- K. INSERT 120 MATCHING PAYMENTS
-- Each payment exactly equals the SUM(quantity * price) of its order items.
INSERT INTO payments
    (order_id, payment_date, amount, payment_method, payment_status)
SELECT o.order_id,
       o.order_date + INTERVAL '15 minutes',
       SUM(oi.quantity * oi.unit_price)::NUMERIC(12,2),
       CASE WHEN RIGHT(o.order_reference, 4)::INTEGER % 5 = 0 THEN 'PayPal'
            WHEN RIGHT(o.order_reference, 4)::INTEGER % 7 = 0 THEN 'Apple Pay'
            WHEN RIGHT(o.order_reference, 4)::INTEGER % 11 = 0 THEN 'Bank Transfer'
            ELSE 'Card' END,
       'Paid'
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.order_reference LIKE 'SS-ORD-2026-%'
GROUP BY o.order_id, o.order_date, o.order_reference
ON CONFLICT (order_id) DO NOTHING;

COMMIT;

-- L. CHECK TOTAL ROW COUNTS - NO TABLE SHOULD HAVE FEWER THAN 30
SELECT 'customers' AS table_name, COUNT(*) AS total_records FROM customers
UNION ALL SELECT 'categories', COUNT(*) FROM categories
UNION ALL SELECT 'suppliers', COUNT(*) FROM suppliers
UNION ALL SELECT 'employees', COUNT(*) FROM employees
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'inventory', COUNT(*) FROM inventory
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'payments', COUNT(*) FROM payments
ORDER BY table_name;

-- M. OPTIONAL BUSINESS QUERY: LOW-STOCK PRODUCTS
-- Select this query separately later if you want a business-focused output.
-- SELECT p.sku, p.product_name, i.stock_quantity, i.reorder_level,
--        s.supplier_name
-- FROM inventory i
-- JOIN products p ON p.product_id = i.product_id
-- JOIN suppliers s ON s.supplier_id = i.supplier_id
-- WHERE i.stock_quantity < i.reorder_level
-- ORDER BY i.stock_quantity ASC, p.product_name;


-- ========================================================================================
-- SECTION 02 / 10  02_Constraint_Verification.sql
-- Source: Uploaded original source · PK, FK, UNIQUE, CHECK constraints
-- ========================================================================================

SELECT
    CASE c.contype
        WHEN 'p' THEN 'PRIMARY KEY'
        WHEN 'f' THEN 'FOREIGN KEY'
        WHEN 'u' THEN 'UNIQUE'
        WHEN 'c' THEN 'CHECK'
    END AS constraint_type,
    COUNT(*) AS total_rules
FROM pg_catalog.pg_constraint AS c
JOIN pg_catalog.pg_class AS t
    ON t.oid = c.conrelid
JOIN pg_catalog.pg_namespace AS n
    ON n.oid = t.relnamespace
WHERE n.nspname = 'public'
  AND t.relname IN (
      'customers', 'categories', 'suppliers', 'employees',
      'products', 'inventory', 'orders', 'order_items', 'payments'
  )
  AND c.contype IN ('p','f','u','c')
GROUP BY c.contype
ORDER BY CASE c.contype
    WHEN 'p' THEN 1
    WHEN 'f' THEN 2
    WHEN 'u' THEN 3
    WHEN 'c' THEN 4
END;


-- ========================================================================================
-- SECTION 03 / 10  03_Transaction_Lines_and_Reconciliation.sql
-- Source: Recovered from presentation speaker notes · Supporting check
-- ========================================================================================

-- Purchase-line output (10 illustrative rows)
SELECT o.order_reference, o.order_date::DATE AS order_date,
       c.first_name || ' ' || c.last_name AS customer, p.product_name,
       oi.quantity, oi.unit_price,
       (oi.quantity * oi.unit_price)::NUMERIC(12,2) AS line_total
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
ORDER BY o.order_reference, oi.order_item_id
LIMIT 10;

-- Independent payment reconciliation
WITH order_totals AS (
 SELECT o.order_id, SUM(oi.quantity * oi.unit_price) AS order_total
 FROM orders o LEFT JOIN order_items oi ON o.order_id = oi.order_id
 GROUP BY o.order_id
)
SELECT COUNT(*) AS orders_checked,
 COUNT(*) FILTER (WHERE ot.order_total IS NULL) AS orders_without_items,
 COUNT(*) FILTER (WHERE p.payment_id IS NULL) AS orders_without_payment,
 COUNT(*) FILTER (WHERE p.payment_id IS NOT NULL AND p.amount <> ot.order_total) AS payment_mismatches
FROM order_totals ot LEFT JOIN payments p ON ot.order_id = p.order_id;


-- ========================================================================================
-- SECTION 04 / 10  04_Query_1_Top_Selling_Products.sql
-- Source: Recovered from presentation speaker notes · Query 1
-- ========================================================================================

-- Query 1: Highest-revenue products in September 2026
SELECT
    p.sku,
    p.product_name,
    SUM(oi.quantity) AS units_sold,
    COUNT(DISTINCT o.order_id) AS number_of_orders,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS sales_revenue_gbp
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN payments pay ON o.order_id = pay.order_id
WHERE o.order_date >= '2026-09-01'
  AND o.order_date < '2026-10-01'
  AND o.order_status IN ('Shipped', 'Completed')
  AND pay.payment_status = 'Paid'
GROUP BY p.product_id, p.sku, p.product_name
ORDER BY sales_revenue_gbp DESC, units_sold DESC
LIMIT 10;

-- SQL SCRIPT — September totals:
-- Query 2: Verify September totals
SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity) AS total_units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue_gbp
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN payments pay ON o.order_id = pay.order_id
WHERE o.order_date >= '2026-09-01'
  AND o.order_date < '2026-10-01'
  AND o.order_status IN ('Shipped', 'Completed')
  AND pay.payment_status = 'Paid';


-- ========================================================================================
-- SECTION 05 / 10  05_Query_2_Category_Sales.sql
-- Source: Recovered from presentation speaker notes · Query 2
-- ========================================================================================

-- Slide 13 — Business Question 2: Revenue by product category
-- September 2026; only paid shipped/completed orders.
WITH category_sales AS (
    SELECT
        c.category_id,
        c.category_name,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(oi.quantity) AS units_sold,
        SUM(oi.quantity * oi.unit_price) AS revenue_gbp
    FROM categories c
    JOIN products p ON c.category_id = p.category_id
    JOIN order_items oi ON p.product_id = oi.product_id
    JOIN orders o ON oi.order_id = o.order_id
    JOIN payments pay ON o.order_id = pay.order_id
    WHERE o.order_date >= '2026-09-01'
      AND o.order_date < '2026-10-01'
      AND o.order_status IN ('Shipped', 'Completed')
      AND pay.payment_status = 'Paid'
    GROUP BY c.category_id, c.category_name
)
SELECT
    category_name,
    total_orders,
    units_sold,
    ROUND(revenue_gbp, 2) AS revenue_gbp,
    ROUND(100.0 * revenue_gbp / SUM(revenue_gbp) OVER (), 1) AS revenue_share_pct
FROM category_sales
ORDER BY revenue_gbp DESC
LIMIT 10;

-- Verification query: Revenue figures should match slide 12.
SELECT
    COUNT(DISTINCT c.category_id) AS categories_with_sales,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity) AS total_units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_revenue_gbp
FROM categories c
JOIN products p ON c.category_id = p.category_id
JOIN order_items oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
JOIN payments pay ON o.order_id = pay.order_id
WHERE o.order_date >= '2026-09-01'
  AND o.order_date < '2026-10-01'
  AND o.order_status IN ('Shipped', 'Completed')
  AND pay.payment_status = 'Paid';


-- ========================================================================================
-- SECTION 06 / 10  06_Query_3_Top_Customers.sql
-- Source: Recovered from presentation speaker notes · Query 3
-- ========================================================================================

-- Business Question 3: Top 10 customers by spending, September 2026
SELECT
    c.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.city,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity) AS units_purchased,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_spent_gbp,
    ROUND(SUM(oi.quantity * oi.unit_price) /
          COUNT(DISTINCT o.order_id), 2) AS average_order_value_gbp
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN payments pay ON o.order_id = pay.order_id
WHERE o.order_date >= '2026-09-01'
  AND o.order_date < '2026-10-01'
  AND o.order_status IN ('Shipped', 'Completed')
  AND pay.payment_status = 'Paid'
GROUP BY c.customer_id, c.first_name, c.last_name, c.city
ORDER BY total_spent_gbp DESC
LIMIT 10;

-- Verification query
SELECT
    COUNT(DISTINCT c.customer_id) AS customers_who_purchased,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity) AS total_units_purchased,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_customer_spending_gbp
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN payments pay ON o.order_id = pay.order_id
WHERE o.order_date >= '2026-09-01'
  AND o.order_date < '2026-10-01'
  AND o.order_status IN ('Shipped', 'Completed')
  AND pay.payment_status = 'Paid';


-- ========================================================================================
-- SECTION 07 / 10  07_Query_4_Low_Stock.sql
-- Source: Recovered from presentation speaker notes · Query 4
-- ========================================================================================

-- Business Question 4: Products at or below their reorder level
SELECT
    p.sku,
    p.product_name,
    i.stock_quantity,
    i.reorder_level,
    GREATEST(i.reorder_level - i.stock_quantity, 0) AS units_below_reorder,
    s.supplier_name,
    s.lead_time_days
FROM inventory i
JOIN products p ON i.product_id = p.product_id
JOIN suppliers s ON i.supplier_id = s.supplier_id
WHERE i.stock_quantity <= i.reorder_level
  AND p.is_active = TRUE
ORDER BY units_below_reorder DESC,
         s.lead_time_days DESC,
         p.product_name
LIMIT 10;

-- Inventory verification summary
SELECT
    COUNT(*) AS total_active_products,
    COUNT(i.inventory_id) AS products_with_inventory,
    COUNT(*) FILTER (WHERE i.stock_quantity <= i.reorder_level)
        AS products_at_or_below_reorder,
    COUNT(*) FILTER (WHERE i.stock_quantity = 0) AS out_of_stock_products,
    COUNT(*) FILTER (WHERE i.inventory_id IS NULL)
        AS products_without_inventory
FROM products p
LEFT JOIN inventory i ON p.product_id = i.product_id
WHERE p.is_active = TRUE;


-- ========================================================================================
-- SECTION 08 / 10  08_Query_5_Supplier_Risk.sql
-- Source: Recovered from presentation speaker notes · Query 5
-- ========================================================================================

-- Business Question 5: Supplier product coverage and stock risk
SELECT
    s.supplier_code,
    s.supplier_name,
    COUNT(i.product_id) AS products_supplied,
    COUNT(i.product_id) FILTER (
        WHERE i.stock_quantity <= i.reorder_level
    ) AS products_needing_review,
    s.lead_time_days,
    SUM(COALESCE(i.stock_quantity, 0)) AS total_stock_units
FROM suppliers s
LEFT JOIN inventory i
    ON s.supplier_id = i.supplier_id
GROUP BY s.supplier_id,
         s.supplier_code,
         s.supplier_name,
         s.lead_time_days
ORDER BY products_supplied DESC,
         products_needing_review DESC,
         s.lead_time_days DESC
LIMIT 10;

-- Verification: number of products per supplier and reorder alerts
WITH supplier_coverage AS (
    SELECT
        s.supplier_id,
        COUNT(i.product_id) AS products_supplied,
        COUNT(i.product_id) FILTER (
            WHERE i.stock_quantity <= i.reorder_level
        ) AS low_stock_products
    FROM suppliers s
    LEFT JOIN inventory i
        ON s.supplier_id = i.supplier_id
    GROUP BY s.supplier_id
)
SELECT
    COUNT(*) AS suppliers_checked,
    SUM(products_supplied) AS total_product_assignments,
    MIN(products_supplied) AS minimum_products_per_supplier,
    MAX(products_supplied) AS maximum_products_per_supplier,
    SUM(low_stock_products) AS products_at_or_below_reorder
FROM supplier_coverage;


-- ========================================================================================
-- SECTION 09 / 10  09_Transformation_1_Monthly_Sales.sql
-- Source: Uploaded original source · Before / materialised view / validation
-- ========================================================================================

-- SHOPSMART | Task 2 | Transformation 1: Monthly Sales Summary
-- Run each section separately in pgAdmin 4 connected to shopsmart_db.
-- These queries use the same filters as Slides 12–14:
-- Paid + Shipped/Completed transactions, across all available months.

-- STEP 1 — BEFORE: raw line-item transactions (12 illustrative rows)
SELECT
    TO_CHAR(o.order_date, 'YYYY-MM') AS sales_month,
    o.order_reference,
    p.product_name,
    oi.quantity,
    oi.unit_price,
    ROUND(oi.quantity * oi.unit_price, 2) AS line_revenue_gbp
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products p ON p.product_id = oi.product_id
JOIN payments pay ON pay.order_id = o.order_id
WHERE o.order_status IN ('Shipped', 'Completed')
  AND pay.payment_status = 'Paid'
ORDER BY o.order_date, o.order_reference, oi.order_item_id
LIMIT 12;

-- STEP 2 — TRANSFORM: persisted monthly aggregated output.
-- Materialized view caches the grouped result. Refresh is necessary after
-- any changes to source tables; no base table is modified by this code.
CREATE MATERIALIZED VIEW IF NOT EXISTS shopsmart_monthly_sales AS
SELECT
    DATE_TRUNC('month', o.order_date)::DATE AS month_start,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue_gbp
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN payments pay ON pay.order_id = o.order_id
WHERE o.order_status IN ('Shipped', 'Completed')
  AND pay.payment_status = 'Paid'
GROUP BY DATE_TRUNC('month', o.order_date)::DATE
WITH DATA;

REFRESH MATERIALIZED VIEW shopsmart_monthly_sales;

SELECT
    TO_CHAR(month_start, 'YYYY-MM') AS sales_month,
    total_orders,
    units_sold,
    revenue_gbp
FROM shopsmart_monthly_sales
ORDER BY month_start;

-- STEP 3 — VALIDATE: underlying transactions reconcile to the summary.
WITH raw_monthly AS (
    SELECT
        DATE_TRUNC('month', o.order_date)::DATE AS month_start,
        COUNT(DISTINCT o.order_id) AS raw_orders,
        SUM(oi.quantity) AS raw_units,
        ROUND(SUM(oi.quantity * oi.unit_price), 2) AS raw_revenue_gbp
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.order_id
    JOIN payments pay ON pay.order_id = o.order_id
    WHERE o.order_status IN ('Shipped', 'Completed')
      AND pay.payment_status = 'Paid'
    GROUP BY DATE_TRUNC('month', o.order_date)::DATE
)
SELECT
    TO_CHAR(r.month_start, 'YYYY-MM') AS sales_month,
    r.raw_orders,
    m.total_orders AS summary_orders,
    r.raw_units,
    m.units_sold AS summary_units,
    r.raw_revenue_gbp,
    m.revenue_gbp AS summary_revenue_gbp,
    CASE WHEN r.raw_orders = m.total_orders
               AND r.raw_units = m.units_sold
               AND r.raw_revenue_gbp = m.revenue_gbp
         THEN 'MATCH' ELSE 'MISMATCH' END AS validation_status
FROM raw_monthly r
LEFT JOIN shopsmart_monthly_sales m ON m.month_start = r.month_start
ORDER BY r.month_start;


-- ========================================================================================
-- SECTION 10 / 10  10_Transformation_2_Inventory_Summary.sql
-- Source: Recovered from presentation speaker notes · Before / materialised view / validation
-- ========================================================================================

-- ShopSmart Task 2 - Slide 18
-- SQL transformation 2: Product-level inventory -> materialized category summary
-- Execute against shopsmart_db.
-- Source data are fictional/synthetic. All quantities are inventory snapshot values.

-- STEP 1: BEFORE - detail sample (12 rows)
SELECT
    c.category_name,
    p.sku,
    p.product_name,
    i.stock_quantity,
    i.reorder_level,
    GREATEST(i.reorder_level - i.stock_quantity, 0) AS units_below_reorder,
    s.supplier_name,
    s.lead_time_days
FROM inventory i
JOIN products p ON i.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
JOIN suppliers s ON i.supplier_id = s.supplier_id
WHERE p.is_active = TRUE
ORDER BY
    (i.stock_quantity <= i.reorder_level) DESC,
    units_below_reorder DESC,
    s.lead_time_days DESC
LIMIT 12;

-- STEP 2: TRANSFORMATION - stored category-level summary
CREATE MATERIALIZED VIEW IF NOT EXISTS shopsmart_inventory_category_summary AS
SELECT
    c.category_id,
    c.category_name,
    COUNT(*) AS products_tracked,
    SUM(i.stock_quantity) AS total_stock_units,
    COUNT(*) FILTER (WHERE i.stock_quantity <= i.reorder_level)
        AS products_at_reorder,
    SUM(GREATEST(i.reorder_level - i.stock_quantity, 0))
        AS units_below_reorder,
    ROUND(SUM(i.stock_quantity * p.unit_price), 2)
        AS estimated_retail_stock_value_gbp
FROM inventory i
JOIN products p ON i.product_id = p.product_id
JOIN categories c ON p.category_id = c.category_id
WHERE p.is_active = TRUE
GROUP BY c.category_id, c.category_name
WITH DATA;

-- Refresh saved result after source-data changes.
REFRESH MATERIALIZED VIEW shopsmart_inventory_category_summary;

-- STEP 2: AFTER - top ten categories by alerts and shortfall
SELECT
    category_name,
    products_tracked,
    total_stock_units,
    products_at_reorder,
    units_below_reorder,
    estimated_retail_stock_value_gbp
FROM shopsmart_inventory_category_summary
ORDER BY
    products_at_reorder DESC,
    units_below_reorder DESC,
    category_name
LIMIT 10;

-- STEP 3: VALIDATE - independently reconcile aggregated totals
WITH original AS (
    SELECT
        COUNT(*) AS source_products,
        SUM(i.stock_quantity) AS source_units,
        COUNT(*) FILTER (
            WHERE i.stock_quantity <= i.reorder_level
        ) AS source_alerts,
        SUM(GREATEST(i.reorder_level - i.stock_quantity, 0))
            AS source_shortfall
    FROM inventory i
    JOIN products p ON i.product_id = p.product_id
    WHERE p.is_active = TRUE
),
transformed AS (
    SELECT
        COUNT(*) AS categories_in_summary,
        SUM(products_tracked) AS summary_products,
        SUM(total_stock_units) AS summary_units,
        SUM(products_at_reorder) AS summary_alerts,
        SUM(units_below_reorder) AS summary_shortfall
    FROM shopsmart_inventory_category_summary
)
SELECT
    t.categories_in_summary,
    o.source_products,
    t.summary_products,
    o.source_alerts,
    t.summary_alerts,
    CASE
        WHEN o.source_products = t.summary_products
         AND o.source_units = t.summary_units
         AND o.source_alerts = t.summary_alerts
         AND o.source_shortfall = t.summary_shortfall
        THEN 'MATCH'
        ELSE 'CHECK'
    END AS validation_status
FROM original o
CROSS JOIN transformed t;

