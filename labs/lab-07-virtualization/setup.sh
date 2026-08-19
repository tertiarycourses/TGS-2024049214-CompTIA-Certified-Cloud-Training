#!/usr/bin/env bash
# Lab 7 — Virtualization with QEMU/KVM
# Platform: Killercoda Ubuntu Playground — https://killercoda.com/playgrounds/scenario/ubuntu
# (Killercoda runs nested under KVM, so QEMU TCG software emulation is used.)
# Builds Steps 1-5: QEMU tooling, the qcow2 disk, the linked clone and the Alpine ISO.
set -euo pipefail

echo "==> Step 1: Installing QEMU and libvirt tools"
apt update && apt install -y qemu-system-x86 qemu-utils libvirt-clients libvirt-daemon-system bridge-utils virtinst cloud-image-utils

echo "==> Step 2: Creating a virtual disk (VM storage, local)"
mkdir -p /var/vm && cd /var/vm
qemu-img create -f qcow2 vm1.qcow2 2G
qemu-img info vm1.qcow2

echo "==> Step 3: Cloning the disk (linked clone)"
qemu-img create -f qcow2 -F qcow2 -b vm1.qcow2 vm2.qcow2
ls -lh vm*.qcow2
qemu-img info vm2.qcow2

echo "==> Step 4: Examining the host's virtualization capability"
egrep -c '(vmx|svm)' /proc/cpuinfo || true
lscpu | grep -i virtual || true

echo "==> Step 5: Downloading the Alpine ISO for the tiny VM boot"
cd /var/vm
wget -q https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/x86_64/alpine-virt-3.19.1-x86_64.iso

echo
echo "You should now see: /var/vm/vm1.qcow2 (2 GiB qcow2), /var/vm/vm2.qcow2 as a thin"
echo "linked clone backed by vm1.qcow2, and the Alpine virt ISO downloaded."
echo "Next: boot the VM with the Step 5 qemu-system-x86_64 command in the README and work"
echo "through Steps 6-8, then 'bash cleanup.sh'."
