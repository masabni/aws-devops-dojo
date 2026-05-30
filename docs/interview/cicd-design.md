# Designing a CI/CD deployment pipeline

> To be filled in after Phases 4 & 9 (GitHub Actions, then CodePipeline).

**Question as asked:** "Design a CI/CD pipeline that auto-tests and auto-deploys."

**60-second answer:** _(fill in)_

**Pipeline stages to walk through:**
- Source (push/PR) → Test (unit) → Build (Docker image, immutable SHA tag) →
  Push (ECR) → Deploy (ECS rolling / CodeDeploy blue-green) → (optional) approval gate.

**Auth:** GitHub OIDC → assume-role (no static keys). AWS-native uses service roles.

**Safe deploys:** health-check-gated rolling update; rollback on failed health checks;
blue/green for instant rollback.

**GitHub Actions vs CodePipeline:** _(fill in the comparison you lived through)_
