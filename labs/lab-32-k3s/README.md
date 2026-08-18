# Lab 32 — Container Orchestration with Kubernetes (k3s)

In this lab you will install **k3s** (a minimal, single-binary Kubernetes), deploy an app, expose it, scale it, and watch a rolling update — the canonical workload-orchestration platform on every cloud.

Run all commands on the Killercoda Ubuntu Playground:
https://killercoda.com/playgrounds/scenario/ubuntu

---

## Step 1 — Install k3s

```bash
apt update && apt install -y curl
curl -sfL https://get.k3s.io | sh -
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
kubectl get nodes
```

---

## Step 2 — Deploy an application

```bash
cat > app.yaml <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata: { name: web }
spec:
  replicas: 3
  selector: { matchLabels: { app: web } }
  template:
    metadata: { labels: { app: web } }
    spec:
      containers:
      - name: web
        image: nginx:1.26-alpine
        ports: [{ containerPort: 80 }]
---
apiVersion: v1
kind: Service
metadata: { name: web }
spec:
  type: NodePort
  selector: { app: web }
  ports: [{ port: 80, nodePort: 30080 }]
EOF

kubectl apply -f app.yaml
kubectl rollout status deploy/web
kubectl get pods,svc
curl -s http://localhost:30080 | head -3
```

---

## Step 3 — Scale (horizontal)

```bash
kubectl scale deploy/web --replicas=5
kubectl get pods -l app=web
```

This is the **horizontal scaling** primitive from Lab 19, but managed.

---

## Step 4 — Rolling update (Lab 12 idea, K8s-native)

```bash
kubectl set image deploy/web web=nginx:1.27-alpine
kubectl rollout status deploy/web
kubectl rollout history deploy/web
```

Rollback if anything breaks:

```bash
kubectl rollout undo deploy/web
```

---

## Step 5 — Persistent volume

```bash
cat > pvc.yaml <<'EOF'
apiVersion: v1
kind: PersistentVolumeClaim
metadata: { name: data }
spec:
  accessModes: [ReadWriteOnce]
  resources: { requests: { storage: 100Mi } }
EOF
kubectl apply -f pvc.yaml
kubectl get pvc
```

k3s ships with `local-path` provisioner — equivalent to AWS EBS / Azure Disk.

---

## Step 6 — Liveness probe (self-healing)

```bash
kubectl patch deploy/web --type=json -p '[
  {"op":"add","path":"/spec/template/spec/containers/0/livenessProbe",
   "value":{"httpGet":{"path":"/","port":80},"initialDelaySeconds":3,"periodSeconds":5}}
]'
kubectl get pods -l app=web
```

If a pod fails its probe, the kubelet restarts it. **Self-healing**.

---

## Step 7 — RBAC (Lab 24 idea, K8s-native)

```bash
kubectl create role pod-reader --verb=get,list --resource=pods
kubectl create rolebinding alice-pods --role=pod-reader --user=alice
kubectl auth can-i list pods --as alice
kubectl auth can-i delete pods --as alice
```

---

## Step 8 — Map K8s ↔ exam objectives

| K8s primitive | CV0-004 concept |
|---------------|-----------------|
| Deployment | Workload orchestration |
| Service | Application/network load balancer |
| ConfigMap / Secret | CaC + Secrets management |
| HPA | Horizontal scaling |
| PVC | Persistent volume |
| RBAC | Authorization model |
| NetworkPolicy | Security group |

---

## Step 9 — Cleanup

```bash
kubectl delete -f app.yaml
kubectl delete pvc data
/usr/local/bin/k3s-uninstall.sh
```

---

## What you learned
- k3s gives you a real cluster in one shell command.
- Deployments, services, scaling, rolling updates, RBAC.
- K8s implements every cloud-orchestration primitive on the exam.

## Free tools used
- k3s — https://k3s.io
- kubectl — bundled
- Minikube (alternative) — https://minikube.sigs.k8s.io
- k9s (terminal UI) — https://k9scli.io
- Lens Desktop (free) — https://k8slens.dev
- Killercoda K8s playground — https://killercoda.com/playgrounds/scenario/kubernetes
