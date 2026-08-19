# Lab 8 — Relational vs Non-Relational Databases

In this lab you will run a **self-managed** Postgres (relational) and a **provider-managed-style** MongoDB (non-relational), compare schemas and queries, and discuss when to choose each.

## Lab platform

Run all commands on the **Killercoda Ubuntu Playground**:

https://killercoda.com/playgrounds/scenario/ubuntu

---

## Step 1 — Install Docker

```bash
apt update && apt install -y docker.io postgresql-client
systemctl start docker
```

---

## Step 2 — Self-managed Postgres (you handle everything)

```bash
docker run -d --name pg \
  -e POSTGRES_PASSWORD=cloud \
  -p 5432:5432 \
  postgres:16

sleep 5
PGPASSWORD=cloud psql -h 127.0.0.1 -U postgres -c "SELECT version();"
```

You picked the version, set the password, manage backups. **Self-managed** = customer-owned lifecycle.

---

## Step 3 — Create a relational schema

```bash
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
```

Strict schema, foreign keys, JOIN — relational strengths.

---

## Step 4 — Provider-managed-style MongoDB

```bash
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
```

No schema enforced, nested documents, no JOIN. Suitable for variable-shape data.

---

## Step 5 — Compare strengths

| Need | Relational (Postgres) | Non-relational (Mongo) |
|------|----------------------|------------------------|
| Strict schema, ACID | ✅ | partial |
| Multi-table JOIN | ✅ | ❌ |
| Variable structure | ❌ | ✅ |
| Horizontal scale-out | harder | built-in sharding |
| Examples | Banking, ERP | IoT, catalog, sessions |

---

## Step 6 — Provider-managed equivalents

| Engine | AWS | Azure | GCP |
|--------|-----|-------|-----|
| Postgres | RDS / Aurora | Azure Database for Postgres | Cloud SQL |
| MongoDB | DocumentDB | Cosmos DB (Mongo API) | Firestore |
| Redis | ElastiCache | Azure Cache for Redis | Memorystore |

In **provider-managed** the cloud handles patching, HA, backups; you only manage data and connections.

---

## Step 7 — Cleanup

```bash
docker rm -f pg mongo
```

---

## Test it

Run these checks to prove the lab worked before you move on:

```bash
docker ps --filter name=pg --filter name=mongo --format '{{.Names}}\t{{.Status}}'
PGPASSWORD=cloud psql -h 127.0.0.1 -U postgres -c "\dt"
PGPASSWORD=cloud psql -h 127.0.0.1 -U postgres -c "SELECT c.name, SUM(o.amount) FROM customers c JOIN orders o ON o.customer_id=c.id GROUP BY c.name;"
docker exec -i mongo mongosh --quiet --eval 'db.getSiblingDB("shop").customers.countDocuments({})'
```

**Expected:** Run this before Step 7. Both `pg` and `mongo` are **Up**; `\dt` lists the `customers` and `orders` tables; the JOIN returns `Alice | 111.50` and `Bob | 5.00`; and MongoDB reports `2` customer documents — the same business data expressed relationally and as nested documents.

---

## What you learned
- Relational vs non-relational data models.
- Self-managed vs provider-managed responsibility split.
- When to pick each engine.

## Free tools used
- PostgreSQL — https://www.postgresql.org
- MongoDB Community — https://www.mongodb.com/try/download/community
- DB Fiddle (web SQL sandbox) — https://www.db-fiddle.com
