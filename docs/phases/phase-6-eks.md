# Phase 6 — EKS

**Goal:** run the *same* Tasklet image on Kubernetes (EKS) and feel the ECS-vs-EKS
difference firsthand.

## Build
- `infra/eks/`: EKS cluster + a small managed node group (or Fargate profile), in the
  foundation subnets. IAM roles for service accounts (IRSA) for DynamoDB access.
- K8s manifests: Deployment (2 replicas), Service, Ingress (AWS Load Balancer Controller)
  → ALB. `readinessProbe`/`livenessProbe` → `/readyz` / `/healthz`.
- HorizontalPodAutoscaler on CPU (mirrors Phase 3 on the K8s side).

## Interview angle
- ECS vs EKS: control-plane cost, operational overhead, portability, ecosystem.
- When EKS is worth it (multi-cloud, complex orchestration, existing K8s skills) vs when
  ECS Fargate is the simpler right answer.
- IRSA vs ECS task roles for pod-level AWS permissions.
- K8s probes ↔ ALB health checks.

## Cost note
**EKS control plane is ~$0.10/hr (~$73/mo) even when idle.** This is the most expensive
phase — apply at the start of a session, finish, and **`terraform destroy` the same day.**
