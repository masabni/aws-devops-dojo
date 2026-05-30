# Phase 9 — CodePipeline / CodeBuild

**Goal:** re-implement the Phase 4 pipeline using AWS-native CI/CD and compare the two.

## Build (`infra/cicd/`, AWS-native variant)
- **CodeBuild** project: `buildspec.yml` → test → build image → push to ECR.
- **CodePipeline**: Source (GitHub via CodeStar connection) → Build (CodeBuild) →
  Deploy (ECS rolling or CodeDeploy blue/green).
- IAM roles for CodeBuild/CodePipeline.

## Interview angle → `docs/interview/cicd-design.md`
- CodePipeline stages/actions/artifacts vs a GitHub Actions workflow.
- CodeDeploy blue/green vs ECS rolling update.
- When AWS-native CI/CD beats GitHub Actions (tighter IAM, all-in-AWS governance) and when
  it doesn't (ecosystem, portability, simplicity).

## Cost note
CodePipeline ~$1/active pipeline/mo; CodeBuild per-minute. Deploys hit the billable ECS
stack — **destroy at session end.**
