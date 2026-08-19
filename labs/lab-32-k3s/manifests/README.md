# Lab 32 — Kubernetes manifests

Apply-ready YAML for every object Lab 32 creates. Each file matches the names,
labels, images, ports and replica counts used in the lab's inline YAML and
`kubectl` commands, so you can apply these instead of typing the heredocs.

Run them on the **Killercoda Kubernetes Playground** —
https://killercoda.com/playgrounds/scenario/kubernetes — where `kubectl` is
already configured against a real cluster.

| File | Lab step | Apply with |
|------|----------|------------|
| [`deployment.yaml`](deployment.yaml) | Step 2 — the `web` Deployment, 3 replicas of `nginx:1.26-alpine` | `kubectl apply -f manifests/deployment.yaml` |
| [`service.yaml`](service.yaml) | Step 2 — the NodePort Service on port 30080 | `kubectl apply -f manifests/service.yaml` |
| [`pvc.yaml`](pvc.yaml) | Step 5 — the `data` PersistentVolumeClaim (100Mi, ReadWriteOnce) | `kubectl apply -f manifests/pvc.yaml` |
| [`liveness.yaml`](liveness.yaml) | Step 6 — the `web` Deployment with the liveness probe already set (self-healing) | `kubectl apply -f manifests/liveness.yaml` |
| [`rbac.yaml`](rbac.yaml) | Step 7 — the `pod-reader` Role and the `alice-pods` RoleBinding | `kubectl apply -f manifests/rbac.yaml` |

Apply everything at once:

```bash
kubectl apply -f manifests/
```

`liveness.yaml` is the same `web` Deployment as `deployment.yaml` with the
probe added, so applying it updates the existing Deployment in place — exactly
what the Step 6 `kubectl patch` does.

Tear down:

```bash
kubectl delete -f manifests/
```
