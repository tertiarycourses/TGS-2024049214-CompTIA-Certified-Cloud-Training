# Lab 7 — Virtualization with QEMU/KVM

In this lab you will create a virtual machine with QEMU, examine virtualization concepts (clone, host affinity, hardware pass-through, VM networks), and compare it to the container model from Lab 6.

Run all commands on the Killercoda Ubuntu Playground:
https://killercoda.com/playgrounds/scenario/ubuntu

> Note: Killercoda runs nested under KVM, so we use **QEMU TCG** (software emulation) instead of full KVM acceleration. The concepts and commands are identical to a real hypervisor.

---

## Step 1 — Install QEMU and libvirt tools

```bash
apt update && apt install -y qemu-system-x86 qemu-utils libvirt-clients libvirt-daemon-system bridge-utils virtinst cloud-image-utils
```

---

## Step 2 — Create a virtual disk (VM storage, local)

```bash
mkdir -p /var/vm && cd /var/vm
qemu-img create -f qcow2 vm1.qcow2 2G
qemu-img info vm1.qcow2
```

`qcow2` is a copy-on-write disk format — the basis of fast **cloning**.

---

## Step 3 — Clone the disk (linked clone)

```bash
qemu-img create -f qcow2 -F qcow2 -b vm1.qcow2 vm2.qcow2
ls -lh vm*.qcow2
qemu-img info vm2.qcow2
```

`vm2.qcow2` is a thin clone — only stores deltas. This is how cloud snapshots and templates work.

---

## Step 4 — Examine the host's virtualization capability

```bash
egrep -c '(vmx|svm)' /proc/cpuinfo
lscpu | grep -i virtual
```

If `vmx` (Intel) or `svm` (AMD) is non-zero, the host supports hardware-assisted virtualization (KVM). That is **hardware pass-through** at the CPU level.

---

## Step 5 — Boot a tiny VM

```bash
cd /var/vm
wget -q https://dl-cdn.alpinelinux.org/alpine/v3.19/releases/x86_64/alpine-virt-3.19.1-x86_64.iso

timeout 30 qemu-system-x86_64 \
  -m 256 \
  -nographic \
  -hda vm1.qcow2 \
  -cdrom alpine-virt-3.19.1-x86_64.iso \
  -boot d \
  -net nic -net user 2>&1 | head -30 || true
```

The VM boots its own kernel — unlike a container, which shares the host kernel.

---

## Step 6 — VM network types

QEMU shows the two main virtual network types from the exam:

```bash
echo "--- User-mode (NAT, default) ---"
echo '-net user creates an isolated NAT — like an overlay network'

echo "--- Bridged (VM joins host LAN) ---"
brctl addbr br0 2>/dev/null || ip link add br0 type bridge
ip link show br0
ip link del br0
```

- **Overlay** = `-net user` — VM traffic encapsulated, NATed.
- **VM network (bridged)** = bridge — VMs appear on the same L2 segment as the host.

---

## Step 7 — Host affinity

In libvirt you pin a VM to a specific host CPU set:

```bash
echo '<vcpu placement="static" cpuset="0-1">2</vcpu>' 
```

`cpuset` = host affinity. The same concept on AWS is **Dedicated Host** + placement groups.

---

## Step 8 — VM vs Container summary

| Aspect | VM (this lab) | Container (Lab 6) |
|--------|---------------|-------------------|
| Kernel | Own kernel | Shares host kernel |
| Boot time | seconds–minutes | milliseconds |
| Disk | qcow2 / raw | layered images |
| Isolation | Hardware-level | Namespace + cgroup |
| Density per host | Tens | Thousands |

---

## Step 9 — Cleanup

```bash
rm -f /var/vm/vm*.qcow2 /var/vm/alpine-virt-3.19.1-x86_64.iso
```

---

## Test it

Run these checks to prove the lab worked before you move on:

```bash
qemu-img info /var/vm/vm1.qcow2
qemu-img info /var/vm/vm2.qcow2 | grep -i backing
ls -lh /var/vm/vm*.qcow2
egrep -c '(vmx|svm)' /proc/cpuinfo
```

**Expected:** Run this before Step 9. `vm1.qcow2` reports `file format: qcow2` with a 2.0 GiB virtual size; `vm2.qcow2` names `vm1.qcow2` as its **backing file** and its on-disk size is only a few hundred KB versus vm1's — proof the linked clone stores deltas only; the CPU flag count is a number (non-zero means the host supports hardware-assisted virtualization).

---

## What you learned
- Create and clone qcow2 disks.
- VM networks: user-mode, bridged, overlay.
- VMs vs containers — when to choose which.

## Free tools used
- QEMU — https://www.qemu.org
- libvirt / virt-install — https://libvirt.org
- Alpine Linux ISO — https://alpinelinux.org
