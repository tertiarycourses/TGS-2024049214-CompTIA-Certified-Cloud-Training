#!/usr/bin/env bash
# Lab 8 — Relational vs Non-Relational Databases
# Platform: Killercoda Ubuntu Playground — https://killercoda.com/playgrounds/scenario/ubuntu
# Builds Steps 1-4: self-managed Postgres with a relational schema, and MongoDB with documents.
set -euo pipefail

echo "==> Step 1: Installing Docker"
apt update && apt install -y docker.io postgresql-client
systemctl start docker

echo "==> Step 2: Starting self-managed Postgres"
docker run -d --name pg \
  -e POSTGRES_PASSWORD=cloud \
  -p 5432:5432 \
  postgres:16

sleep 5
PGPASSWORD=cloud psql -h 127.0.0.1 -U postgres -c "SELECT version();"

echo "==> Step 3: Creating the relational schema"
PGPASSWORD=cloud psql -h 127.0.0.1 -U postgres <<'SQL'
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
SQL

echo "==> Step 4: Starting provider-managed-style MongoDB and loading documents"
docker run -d --name mongo -p 27017:27017 mongo:7
sleep 5
docker exec -i mongo mongosh <<'JS'
use shop
db.customers.insertOne({email:"a@x.com", name:"Alice", orders:[
  {amount: 12.50, item:"pen"},
  {amount: 99.00, item:"chair"}
]})
db.customers.insertOne({email:"b@x.com", name:"Bob", orders:[
  {amount: 5.00, item:"pad"}
]})

db.customers.aggregate([
  {$unwind:"$orders"},
  {$group:{_id:"$name", total:{$sum:"$orders.amount"}}}
])
JS

echo
echo "You should now see: both 'pg' and 'mongo' containers Up, the Postgres JOIN returning"
echo "Alice 111.50 and Bob 5.00, and the Mongo aggregation returning the same totals from"
echo "nested documents."
echo "Next: run the checks in the README's 'Test it' section, then 'bash cleanup.sh'."
