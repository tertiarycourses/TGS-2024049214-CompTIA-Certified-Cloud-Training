# Lab 34 — Troubleshoot Cloud Network Issues

In this lab you will reproduce and resolve the network failures from CV0-004 6.2: **DHCP, DNS, NTP, NAT, HTTP status codes, latency, routing, switching, IP overlap, scope exhaustion**.

## Lab platform

Run all commands on the **Killercoda Ubuntu Playground**:

https://killercoda.com/playgrounds/scenario/ubuntu

> **Ready-made files:** this lab ships [`setup.sh`](setup.sh), [`cleanup.sh`](cleanup.sh) and [`bad-resolv.conf`](bad-resolv.conf) — run `bash setup.sh` to build everything in one go, or follow the steps below to type it yourself.

---

## Step 1 — Install diagnostics

```bash
apt update && apt install -y dnsutils iproute2 iputils-ping curl traceroute mtr-tiny tcpdump iptables docker.io chrony jq
systemctl start docker
```

---

## Step 2 — DNS failure → fix

```bash
echo "nameserver 192.0.2.1" > /tmp/bad-resolv.conf
docker run --rm --dns 192.0.2.1 alpine nslookup example.com 2>&1 | tail -4
echo "Symptom: SERVFAIL / no servers reachable"

# Fix: use a valid resolver
docker run --rm --dns 1.1.1.1 alpine nslookup example.com 2>&1 | tail -4
```

---

## Step 3 — NTP / time skew

```bash
date
hwclock --systohc 2>/dev/null
chronyc tracking 2>/dev/null | head -5 || echo "chrony not running"
chronyc sources 2>/dev/null
```

Clock skew breaks **TLS handshakes**, **MFA tokens**, and **Kerberos**. Always enable an NTP source.

---

## Step 4 — NAT failure

```bash
ip netns add p
ip link add veth0 type veth peer name veth1
ip link set veth1 netns p
ip addr add 10.99.0.1/24 dev veth0; ip link set veth0 up
ip -n p addr add 10.99.0.2/24 dev veth1; ip -n p link set veth1 up; ip -n p link set lo up
ip -n p route add default via 10.99.0.1

# Without NAT — fails
ip -n p ping -c 2 -W 2 8.8.8.8 || echo "Symptom: blocked, no NAT"

# Add MASQUERADE
sysctl -w net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -s 10.99.0.0/24 -o eth0 -j MASQUERADE
ip -n p ping -c 2 8.8.8.8 || echo "Outbound ping may be blocked by host policy"

# Cleanup
iptables -t nat -D POSTROUTING -s 10.99.0.0/24 -o eth0 -j MASQUERADE
ip netns del p
```

---

## Step 5 — HTTP status code triage

```bash
docker run -d --name web -p 8080:80 nginx:alpine
curl -s -o /dev/null -w "URL=%{url_effective} HTTP=%{http_code}\n" http://localhost:8080/missing
curl -s -o /dev/null -w "HTTP=%{http_code}\n" http://localhost:8080/
docker rm -f web
```

| Code | Meaning | Likely cause |
|------|---------|--------------|
| 4xx | Client | Wrong URL, auth, payload |
| 5xx | Server | Backend down, TLS, misconfig |
| 502/504 | LB → upstream | Upstream not responding |
| 429 | Rate limited | Quota / WAF |

---

## Step 6 — Latency / bandwidth (Lab 35 of N+ revisited)

```bash
ping -c 4 1.1.1.1 | tail -2
mtr -rwc 5 1.1.1.1 || true
```

If RTT > expected, traceroute hop-by-hop to find the slow link.

---

## Step 7 — IP overlap & scope exhaustion

```bash
ip route show | grep -E '(192\.168|10\.|172\.)'
echo "If two VPCs/peers share 10.0.0.0/24 — NAT or re-IP one side."
echo "Scope exhaustion: DHCP pool is full → enlarge the subnet or shorten the lease."
```

---

## Step 8 — Routing issues

```bash
ip route get 8.8.8.8
ip route get 10.255.255.255 || true
```

`ip route get` shows which route the kernel selects. Missing or wrong default → no internet.

---

## Step 9 — VLAN / switching issues (concept)

Two common symptoms:
- **Mismatched access vs trunk** — a tagged frame hits an access port → drop.
- **Wrong native VLAN** — frames leak between segments.

In cloud, the equivalent is wrong **subnet → route table** association.

---

## Step 10 — Decision tree

1. Local stack OK? `ip a`, `ss -tlnp`
2. ARP / neighbour OK? `ip neigh`
3. Default route OK? `ip route`
4. DNS OK? `dig`
5. Path OK? `mtr`
6. Service OK? `curl -v`

---

## Test it

Run these checks to prove the lab worked before you move on:

```bash
docker run --rm --dns 1.1.1.1 alpine nslookup example.com | tail -3
chronyc tracking 2>/dev/null | head -5 || timedatectl
ip route get 8.8.8.8
curl -s -o /dev/null -w "root=%{http_code}\n" http://localhost:8080/
curl -s -o /dev/null -w "missing=%{http_code}\n" http://localhost:8080/missing
ping -c 4 1.1.1.1 | tail -2
```

**Expected:** Run the HTTP checks while the `web` container from Step 5 is still running. The good resolver returns an `Address:` line for `example.com` (the `192.0.2.1` resolver returned SERVFAIL / no servers reachable); chrony or `timedatectl` shows a synchronised clock; `ip route get 8.8.8.8` names the outgoing interface and `via` gateway the kernel selected; the two curls return `root=200` and `missing=404` — the 4xx localises the fault to the client request, not the server; and the ping summary shows `0% packet loss` with an average RTT.

---

## What you learned
- A ladder of checks from L2 → L7.
- HTTP status codes localise the failure layer.
- NTP and DNS break "everything else" when they break.

## Free tools used
- dig / nslookup / mtr / traceroute / ip — built-in
- chrony — https://chrony-project.org
- TIS PCAP Analyzer — https://alfredang.github.io/pcapanalyzer/
- HTTP status reference — https://httpstatuses.com

---

## Files in this lab

| File | Purpose |
|------|---------|
| [`setup.sh`](setup.sh) | Runs Step 1, writes the broken resolver file and starts the Step 5 `web` container (the deliberate failures stay yours to reproduce). |
| [`cleanup.sh`](cleanup.sh) | Teardown — removes the `web` container, the Step 4 MASQUERADE rule and namespace `p`, and the resolver file. |
| [`bad-resolv.conf`](bad-resolv.conf) | Step 2 deliberately-unreachable resolver (`192.0.2.1`) used to reproduce the DNS failure. |
