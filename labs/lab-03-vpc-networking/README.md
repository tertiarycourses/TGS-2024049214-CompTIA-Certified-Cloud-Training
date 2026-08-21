# Lab 3 — Cloud Networking with VPC Namespaces

In this lab you will build a virtual private cloud (VPC) entirely with Linux network namespaces. You will create two subnets, a router, NAT to the internet, and a security group rule — exactly the building blocks AWS, Azure and GCP expose as managed services.

## Lab platform

Run all commands on the **Killercoda Ubuntu Playground**:

https://killercoda.com/playgrounds/scenario/ubuntu

> **Ready-made files:** this lab ships [`setup.sh`](setup.sh) and [`cleanup.sh`](cleanup.sh) — run `bash setup.sh` to build everything in one go, or follow the steps below to type it yourself.

---

## Step 1 — Install tools

```bash
apt update && apt install -y iproute2 iptables iputils-ping
```

---

## Step 2 — Create the VPC subnets

A network namespace is an isolated Linux network stack — equivalent to a subnet plus its attached ENIs.

```bash
ip netns add subnet-a
ip netns add subnet-b
ip netns add router

ip netns list
```

---

## Step 3 — Wire the subnets to the router

Use veth pairs as virtual cables.

```bash
ip link add a-r type veth peer name r-a
ip link add b-r type veth peer name r-b

ip link set a-r netns subnet-a
ip link set r-a netns router
ip link set b-r netns subnet-b
ip link set r-b netns router
```

Assign IPs (10.0.1.0/24 and 10.0.2.0/24):

```bash
ip -n subnet-a addr add 10.0.1.10/24 dev a-r
ip -n router   addr add 10.0.1.1/24  dev r-a
ip -n subnet-b addr add 10.0.2.10/24 dev b-r
ip -n router   addr add 10.0.2.1/24  dev r-b

for ns in subnet-a subnet-b router; do
  ip -n $ns link set lo up
done

ip -n subnet-a link set a-r up
ip -n subnet-b link set b-r up
ip -n router link set r-a up
ip -n router link set r-b up
```

---

## Step 4 — Add default routes (the route table)

```bash
ip -n subnet-a route add default via 10.0.1.1
ip -n subnet-b route add default via 10.0.2.1
ip netns exec router sysctl -w net.ipv4.ip_forward=1
```

Test inter-subnet connectivity (peering):

```bash
ip netns exec subnet-a ping -c 2 10.0.2.10
```

---

## Step 5 — Add a security group rule (deny ICMP from B to A)

```bash
ip netns exec router iptables -I FORWARD -s 10.0.2.0/24 -d 10.0.1.0/24 -p icmp -j DROP
ip netns exec subnet-b ping -c 2 -W 2 10.0.1.10 || echo "Blocked by SG"
```

This is the equivalent of an AWS Security Group / Azure NSG / GCP Firewall rule.

---

## Step 6 — Add NAT gateway to the internet

```bash
ip route add 10.0.0.0/16 via 192.168.99.2 dev nat-r 2>/dev/null
sysctl -w net.ipv4.ip_forward=1
iptables -A FORWARD -s 10.0.0.0/16 -o enp1s0 -j ACCEPT
iptables -A FORWARD -i enp1s0 -d 10.0.0.0/16 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.0.0.0/16 -o enp1s0 -j MASQUERADE

ip netns exec subnet-a ping -c 2 -W 2 8.8.8.8
```

This mirrors a cloud **NAT Gateway** for private subnets reaching the internet.

---

## Step 7 — Cleanup

```bash
ip netns del subnet-a
ip netns del subnet-b
ip netns del router
ip link del nat-r 2>/dev/null
iptables -t nat -F POSTROUTING
```

---

## Test it

Run these checks to prove the lab worked before you move on:

```bash
ip netns list
ip netns exec subnet-a ip route show
ip netns exec subnet-a ping -c 2 10.0.2.10
ip netns exec router iptables -L FORWARD -n --line-numbers
ip netns exec subnet-a ping -c 2 -W 2 8.8.8.8
iptables -t nat -L POSTROUTING -n -v
```

**Expected:** Run this before Step 7. `ip netns list` 
subnet-a, subnet-b, router              → PASS
default via 10.0.1.1                    → PASS
10.0.2.10 ping: 2 received, 0% loss     → PASS
FORWARD DROP rule 10.0.2.0/24 → 10.0.1.0/24 → PASS
8.8.8.8 ping: 2 received, 0% loss       → PASS
MASQUERADE on enp1s0                    → PASS

---

## What you learned
- VPCs, subnets, route tables, security groups, and NAT gateways are kernel features.
- Peering = a route + a forwarding rule.
- Security groups operate per-flow at L3/L4.

## Free tools used
- iproute2 / iptables (built-in)
- TIS IP Calculator — https://alfredang.github.io/ipcalculator/

---

## Files in this lab

| File | Purpose |
|------|---------|
| [`setup.sh`](setup.sh) | Runs Steps 1-6 — installs the tools, creates the namespaces, veth pairs, routes, the security-group DROP rule and the NAT gateway. |
| [`cleanup.sh`](cleanup.sh) | Step 7 teardown — deletes the namespaces, the NAT veth and flushes the NAT POSTROUTING chain. |
