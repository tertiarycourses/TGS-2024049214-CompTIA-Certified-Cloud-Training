# Lab 31 — REST & GraphQL APIs

In this lab you will call a public **REST** API, host a local **GraphQL** server, and try a **WebSocket** stream — covering the exam's web-services and integration sub-objectives.

Run all commands on the Killercoda Ubuntu Playground:
https://killercoda.com/playgrounds/scenario/ubuntu

---

## Step 1 — Install tools

```bash
apt update && apt install -y curl jq docker.io websocat
systemctl start docker
```

---

## Step 2 — Call a REST endpoint (CRUD)

The free **JSONPlaceholder** API supports GET/POST/PUT/DELETE.

```bash
curl -s https://jsonplaceholder.typicode.com/posts/1 | jq

# Create
curl -s -X POST https://jsonplaceholder.typicode.com/posts \
  -H 'Content-Type: application/json' \
  -d '{"title":"hello","body":"cloud","userId":1}' | jq

# Update
curl -s -X PUT https://jsonplaceholder.typicode.com/posts/1 \
  -H 'Content-Type: application/json' \
  -d '{"id":1,"title":"changed","body":"x","userId":1}' | jq

# Delete
curl -sI -X DELETE https://jsonplaceholder.typicode.com/posts/1 | head -1
```

REST = stateless verbs over HTTP, one resource per URL.

---

## Step 3 — Host a local GraphQL endpoint

```bash
docker run -d --name gql -p 4000:4000 \
  graphql/swapi-graphql 2>/dev/null || \
docker run -d --name gql -p 4000:4000 \
  -e PORT=4000 node:20-alpine sh -c '
    npm i -g graphql-yoga@4 graphql >/dev/null
    cat > /tmp/server.mjs <<"JS"
import { createYoga, createSchema } from "graphql-yoga"
import { createServer } from "node:http"
const yoga = createYoga({ schema: createSchema({
  typeDefs: `type Query { hello(name: String): String }`,
  resolvers: { Query: { hello: (_,a)=>"Hello "+(a.name||"cloud") } }
})})
createServer(yoga).listen(4000)
JS
    node /tmp/server.mjs'
sleep 8
```

Send a GraphQL query:

```bash
curl -s http://localhost:4000/graphql \
  -H 'Content-Type: application/json' \
  -d '{"query":"{ hello(name:\"Cloud+\") }"}' | jq
```

GraphQL = single endpoint, client picks fields, fewer over-fetches.

---

## Step 4 — REST vs GraphQL vs SOAP vs RPC

| Style | Verb | Payload | Schema |
|-------|------|---------|--------|
| REST | GET/POST/... | JSON | OpenAPI |
| SOAP | POST | XML | WSDL |
| GraphQL | POST | JSON | GraphQL SDL |
| gRPC (RPC) | HTTP/2 | Protobuf | .proto |

---

## Step 5 — WebSocket stream (real-time)

```bash
docker run -d --name echo -p 8765:8080 \
  jmalloc/echo-server
sleep 2

echo "hello-stream" | websocat -n1 ws://localhost:8765/.ws
```

WebSockets keep the TCP connection open — used by chat, dashboards, K8s `kubectl exec`.

---

## Step 6 — Event-driven preview

```bash
docker run -d --name redis -p 6379:6379 redis:7-alpine
sleep 2
( for i in 1 2 3; do
    docker exec redis redis-cli PUBLISH events "msg-$i"
    sleep 1
  done ) &
docker exec redis sh -c 'timeout 5 redis-cli SUBSCRIBE events'
```

Pub/sub = event-driven architecture (Kafka, SNS/SQS, NATS use the same pattern).

---

## Step 7 — Cleanup

```bash
docker rm -f gql echo redis 2>/dev/null
```

---

## Test it

Run these checks to prove the lab worked before you move on:

```bash
curl -s https://jsonplaceholder.typicode.com/posts/1 | jq '.id, .title'
curl -s http://localhost:4000/graphql -H 'Content-Type: application/json' -d '{"query":"{ hello(name:\"Cloud+\") }"}' | jq
echo "hello-stream" | websocat -n1 ws://localhost:8765/.ws
docker ps --filter name=gql --filter name=echo --filter name=redis --format '{{.Names}}\t{{.Status}}'
```

**Expected:** Run this before Step 7. The REST call returns post `1` with its title (stateless GET over HTTP); the GraphQL query returns exactly `{"data":{"hello":"Hello Cloud+"}}` — only the field you asked for, nothing more; `websocat` echoes `hello-stream` back over the open WebSocket; and all three containers (`gql`, `echo`, `redis`) are **Up**.

---

## What you learned
- REST CRUD with curl.
- GraphQL queries return only requested fields.
- WebSockets for streams; pub/sub for events.

## Free tools used
- jsonplaceholder.typicode.com — public REST sandbox
- GraphQL Yoga — https://the-guild.dev/graphql/yoga-server
- websocat — https://github.com/vi/websocat
- Postman free tier — https://www.postman.com
- Hoppscotch (open-source) — https://hoppscotch.io
