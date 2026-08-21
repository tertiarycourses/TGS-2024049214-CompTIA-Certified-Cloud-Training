# Lab 2 — High Availability with HAProxy & Keepalived

In this lab you will simulate a multi-AZ load-balanced deployment by running two backend web servers and an HAProxy load balancer in front of them. You will then add a second HAProxy instance with **Keepalived** so a virtual IP fails over when the primary load balancer dies — the same pattern used by every cloud provider's regional load balancer.

## Lab platform

Run all commands on the **Killercoda Ubuntu Playground**:

https://killercoda.com/playgrounds/scenario/ubuntu

---

## Step 1 — Install HAProxy and Keepalived

```bash
apt update && apt install -y haproxy keepalived docker.io curl
systemctl start docker
```

---

## Step 2 — Launch two backend "AZ" web servers

Each container represents a server in a different Availability Zone.

```bash
docker run -d --name az1 -p 8081:80 nginx:alpine
docker run -d --name az2 -p 8082:80 nginx:alpine

docker exec az1 sh -c 'echo "AZ-1 healthy" > /usr/share/nginx/html/index.html'
docker exec az2 sh -c 'echo "AZ-2 healthy" > /usr/share/nginx/html/index.html'

curl http://localhost:8081
curl http://localhost:8082
```

---

## Step 3 — Configure HAProxy with health checks

> Ready-made file: [`haproxy.cfg`](haproxy.cfg) — you can download it instead of typing this block.

```bash
cat > /etc/haproxy/haproxy.cfg <<'EOF'
global
    daemon
    maxconn 256

defaults
    mode http
    timeout connect 5s
    timeout client 30s
    timeout server 30s

frontend web
    bind *:80
    default_backend azs

backend azs
    balance roundrobin
    option httpchk GET /
    server az1 127.0.0.1:8081 check
    server az2 127.0.0.1:8082 check
EOF

systemctl restart haproxy
```

---

## Step 4 — Verify load balancing

```bash
for i in 1 2 3 4; do curl -s http://localhost/; done
```

You should see responses alternate between AZ-1 and AZ-2 — round-robin across availability zones.

---

## Step 5 — Simulate an AZ failure

```bash
docker stop az1
sleep 3
for i in 1 2 3; do curl -s http://localhost/; done
```

HAProxy's health check marks `az1` down within seconds and routes 100% of traffic to AZ-2. This is the equivalent of an **AZ outage** in a cloud region.

```bash
docker start az1
```

---

## Step 6 — Add Keepalived for VRRP failover

> Ready-made file: [`keepalived.conf`](keepalived.conf) — you can download it instead of typing this block.

```bash
cat > /etc/keepalived/keepalived.conf <<'EOF'
vrrp_instance VI_1 {
    state MASTER
    interface enp1s0
    virtual_router_id 51
    priority 100
    advert_int 1
    authentication { auth_type PASS; auth_pass cloud }
    virtual_ipaddress { 10.0.0.250/24 }
}
EOF

systemctl start keepalived
ip -brief addr show enp1s0
```

The VIP `10.0.0.250` is now floating on this node. In a real two-node setup, when MASTER dies the BACKUP picks up the VIP within ~3 seconds — this is how regional **active-passive** load balancers achieve HA.

---

## Step 7 — Cleanup

```bash
systemctl stop keepalived haproxy
docker rm -f az1 az2
```

---

## Test it

Run these checks to prove the lab worked before you move on:

```bash
docker ps --filter name=az1 --filter name=az2 --format '{{.Names}}\t{{.Status}}'
for i in 1 2 3 4; do curl -s http://localhost/; done
systemctl is-active haproxy
ip -brief addr show eth0 | grep 10.0.0.250
```

**Expected:** Run this before Step 7. Both `az1` and `az2` show as **Up**, the four `curl` calls through HAProxy alternate `AZ-1 healthy` / `AZ-2 healthy` (round-robin across the two simulated availability zones), `haproxy` reports `active`, and the Keepalived VIP `10.0.0.250/24` is listed on `eth0`.

---

## What you learned
- How a cloud load balancer routes traffic across availability zones.
- How active health checks remove unhealthy instances automatically.
- How Keepalived/VRRP provides a floating IP for LB redundancy.

## Free tools used
- HAProxy — https://www.haproxy.org
- Keepalived — https://www.keepalived.org
- Docker — https://www.docker.com

---

## Files in this lab

| File | Purpose |
|------|---------|
| [`haproxy.cfg`](haproxy.cfg) | Step 3 HAProxy config — round-robin across the two simulated AZ backends with health checks. |
| [`keepalived.conf`](keepalived.conf) | Step 6 Keepalived VRRP config — floats the virtual IP 10.0.0.250. |
