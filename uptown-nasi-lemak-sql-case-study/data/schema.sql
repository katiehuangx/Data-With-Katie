CREATE SCHEMA uptown_nasi_lemak;
SET search_path = uptown_nasi_lemak;


CREATE TABLE sales (
  order_id INTEGER PRIMARY KEY,
  customer_id VARCHAR(1),
  order_date DATE,
  food_id INTEGER,
  channel_id INTEGER
);

INSERT INTO sales (order_id, customer_id, order_date, food_id, channel_id) VALUES
(1,  'G', '2025-01-01', 2, 1),
(2,  'A', '2025-01-02', 2, 1),
(3,  'I', '2025-01-03', 1, 2),
(4,  'B', '2025-01-03', 2, 2),
(5,  'H', '2025-01-04', 3, 1),
(6,  'D', '2025-01-04', 2, 1),
(7,  'F', '2025-01-05', 1, 1),
(8,  'E', '2025-01-05', 3, 2),
(9,  'J', '2025-01-06', 1, 1),
(10, 'C', '2025-01-06', 3, 1),

(11, 'A', '2025-01-07', 2, 1),
(12, 'G', '2025-01-07', 2, 1),
(13, 'I', '2025-01-08', 1, 2),
(14, 'B', '2025-01-08', 2, 2),
(15, 'H', '2025-01-09', 3, 2),
(16, 'D', '2025-01-09', 1, 1),
(17, 'F', '2025-01-10', 1, 2),
(18, 'E', '2025-01-10', 3, 2),
(19, 'J', '2025-01-11', 2, 1),
(20, 'C', '2025-01-11', 3, 3),

(21, 'A', '2025-01-12', 2, 2),
(22, 'G', '2025-01-12', 2, 1),
(23, 'I', '2025-01-13', 2, 3),
(24, 'B', '2025-01-13', 1, 1),
(25, 'H', '2025-01-14', 3, 3),
(26, 'D', '2025-01-14', 3, 1),
(27, 'F', '2025-01-15', 3, 3),
(28, 'E', '2025-01-15', 3, 3),
(29, 'J', '2025-01-15', 3, 1),
(30, 'C', '2025-01-15', 1, 2),

(31, 'A', '2025-01-05', 1, 2),
(32, 'A', '2025-01-09', 1, 3),
(33, 'A', '2025-01-12', 3, 3),
(34, 'B', '2025-01-10', 1, 3),
(35, 'I', '2025-01-14', 2, 3),
(36, 'H', '2025-01-15', 3, 3);


CREATE TABLE menu (
  food_id INTEGER,
  food_name VARCHAR(50),
  price INTEGER
);

INSERT INTO menu (food_id, food_name, price) VALUES
  (1, 'Nasi Lemak Ayam Goreng', 12),
  (2, 'Nasi Lemak Sotong', 15),
  (3, 'Nasi Lemak Telur Mata', 8);



CREATE TABLE order_channels (
  channel_id INTEGER,
  channel_name VARCHAR(20)
);

INSERT INTO order_channels (channel_id, channel_name) VALUES
  (1, 'Dine-In'),
  (2, 'Takeaway'),
  (3, 'GrabFood');
