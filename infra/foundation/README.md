# infra/foundation — VPC (Phase 0)

A small VPC reused by every later phase: public + private subnets across 2 AZs, an
internet gateway, and route tables. NAT gateway is **off by default** (it costs ~$32/mo);
dojo Fargate tasks run in public subnets with a public IP instead, which is free.

Subnets are tagged for EKS (`kubernetes.io/role/elb`, `internal-elb`) so Phase 6 can
discover them automatically.

## Apply

```bash
cp backend.hcl.example backend.hcl   # fill in from bootstrap outputs
terraform init -backend-config=backend.hcl
terraform plan
terraform apply     # cost: ~$0 with NAT disabled (a VPC + subnets + IGW are free)
```

## Teardown

Cheap to leave up (no NAT = no hourly cost). Destroy only when fully done with the dojo,
and after the stacks that depend on it (ecs/eks/data) are gone.

```bash
terraform destroy
```
