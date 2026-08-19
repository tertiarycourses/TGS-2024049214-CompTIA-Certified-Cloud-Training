CREATE TABLE customers (
  id SERIAL PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  name TEXT
);
CREATE TABLE orders (
  id SERIAL PRIMARY KEY,
  customer_id INT REFERENCES customers(id),
  amount NUMERIC(10,2)
);
INSERT INTO customers(email, name) VALUES ('a@x.com','Alice'),('b@x.com','Bob');
INSERT INTO orders(customer_id, amount) VALUES (1, 12.50), (1, 99.00), (2, 5.00);

SELECT c.name, SUM(o.amount) AS total
FROM customers c JOIN orders o ON o.customer_id = c.id
GROUP BY c.name;
