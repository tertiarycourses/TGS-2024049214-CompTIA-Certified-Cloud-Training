#!/usr/bin/env bash
# Lab 7 — Virtualization with QEMU/KVM — teardown (Step 9)
# Platform: Killercoda Ubuntu Playground — https://killercoda.com/playgrounds/scenario/ubuntu
set -uo pipefail

echo "==> Step 9: Removing the qcow2 disks and the Alpine ISO"
rm -f /var/vm/vm*.qcow2 /var/vm/alpine-virt-3.19.1-x86_64.iso || true

echo "==> Cleanup done — /var/vm no longer holds the lab disks or the ISO."
