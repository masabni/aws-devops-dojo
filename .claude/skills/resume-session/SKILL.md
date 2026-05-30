---
name: resume-session
description: Use at the start of any aws-devops-dojo session to load context and continue the AWS DevOps practice from where we left off. Triggers on "resume", "where were we", "continue the dojo", "what phase are we on".
---

# Resume the aws-devops-dojo session

Goal: get oriented fast and continue the hands-on AWS practice without re-deciding
settled questions.

## Steps

1. **Read the context, in order:**
   - `CLAUDE.md` — goal, hard rules (esp. cost safety), locked-in decisions, roadmap.
   - `docs/STATUS.md` — the current phase and the exact next actions.
   - The `docs/phases/phase-N-*.md` guide for the current phase.

2. **Check the environment before any AWS work:**
   ```bash
   terraform version 2>&1 | head -1
   aws sts get-caller-identity
   ```
   If Terraform is missing or the AWS token is invalid, surface that first — Phase 0+
   cannot be applied until both are fixed.

3. **Check for live (billable) infra that should have been torn down:**
   ```bash
   aws ecs list-clusters; aws eks list-clusters; \
   aws rds describe-db-clusters --query 'DBClusters[].DBClusterIdentifier'; \
   aws ec2 describe-nat-gateways --filter Name=state,Values=available \
     --query 'NatGateways[].NatGatewayId'
   ```
   If anything is running and we're not actively using it, flag it (cost) and offer to destroy.

4. **Confirm the plan for this session** with the user before applying anything.
   Remember: writing/refactoring Terraform is fine; `terraform apply`/`destroy` always
   needs the user present and confirming.

5. **At session end:** run the cost-safety checklist in `docs/STATUS.md`, tear down
   billable stacks, and update `docs/STATUS.md`.
