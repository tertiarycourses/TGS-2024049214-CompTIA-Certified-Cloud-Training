#!/usr/bin/env bash
# Lab 3 — Cloud Networking with VPC Namespaces
# Platform: Killercoda Ubuntu Playground — https://killercoda.com/playgrounds/scenario/ubuntu
# Builds Steps 1-6: subnets, router, routes, security group rule and the NAT gateway.
set -euo pipefail

echo "==> Step 1: Installing tools"
apt update && apt install -y iproute2 iptables iputils-ping

echo "==> Step 2: Creating the VPC subnets"
ip netns add subnet-a
ip netns add subnet-b
ip netns add router

ip netns list

echo "==> Step 3: Wiring the subnets to the router"
ip link add a-r type veth peer name r-a
ip link add b-r type veth peer name r-b

ip link set a-r netns subnet-a
ip link set r-a netns router
ip link set b-r netns subnet-b
ip link set r-b netns router

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

echo "==> Step 4: Adding default routes (the route table)"
ip -n subnet-a route add default via 10.0.1.1
ip -n subnet-b route add default via 10.0.2.1
ip netns exec router sysctl -w net.ipv4.ip_forward=1

ip netns exec subnet-a ping -c 2 10.0.2.10

echo "==> Step 5: Adding a security group rule (deny ICMP from B to A)"
ip netns exec router iptables -I FORWARD -s 10.0.2.0/24 -d 10.0.1.0/24 -p icmp -j DROP

echo "==> Step 6: Adding the NAT gateway to the internet"
ip link add nat-r type veth peer name r-nat
ip link set r-nat netns router
ip addr add 192.168.99.1/24 dev nat-r
ip -n router addr add 192.168.99.2/24 dev r-nat
ip link set nat-r up
ip -n router link set r-nat up
ip -n router route add default via 192.168.99.1

sysctl -w net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -s 10.0.0.0/16 -o eth0 -j MASQUERADE

echo
echo "You should now see: three namespaces (subnet-a, subnet-b, router), an inter-subnet"
echo "ping working across the router, a DROP rule in the router's FORWARD chain, and a"
echo "MASQUERADE NAT rule for 10.0.0.0/16."
echo "Next: run the checks in the README's 'Test it' section, then 'bash cleanup.sh'."
