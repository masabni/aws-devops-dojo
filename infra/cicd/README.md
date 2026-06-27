# infra/cicd — Phase 4 (GitHub OIDC + deploy role)

Gives GitHub Actions **keyless** access to AWS (no long-lived keys in repo secrets).
Creates a GitHub OIDC identity provider + an IAM role scoped to **ECR push + ECS deploy**
for this repo, on the `main` branch only.

Phase 9 will add CodeBuild + CodePipeline here for an AWS-native comparison.

**Standing cost: $0.** OIDC provider + IAM role are free; leave them up between sessions.

## Apply

```bash
cd infra/cicd
terraform init -backend-config=backend.hcl
terraform apply        # creates the OIDC provider + role
```

> If you already have a GitHub OIDC provider in this account (from another project),
> the apply will error on the duplicate. Import it first:
> ```
> terraform import aws_iam_openid_connect_provider.github \
>   arn:aws:iam::<account>:oidc-provider/token.actions.githubusercontent.com
> ```

## Wire it into GitHub (one-time)

The deploy workflow reads the role ARN from a **repo variable** (not a secret — it isn't
sensitive). After apply:

```bash
terraform output -raw github_actions_role_arn
# then, in the repo:
gh variable set AWS_DEPLOY_ROLE_ARN --body "<that-arn>"
```

## How the pipeline uses this

- `.github/workflows/ci.yml` — PRs / non-main pushes: `npm ci` → typecheck → test → build.
  No AWS access.
- `.github/workflows/deploy.yml` — **manual** (`workflow_dispatch`): assumes this role via
  OIDC → builds image tagged with the commit SHA → pushes to ECR → registers a new task-def
  revision → rolls the ECS service (ALB-health-gated).

## Trust scope (security)

The role's trust policy only allows `sts:AssumeRoleWithWebIdentity` when the OIDC token's:
- `aud` = `sts.amazonaws.com`, **and**
- `sub` = `repo:<owner>/<repo>:ref:refs/heads/main`.

So only workflow runs from this repo, on `main`, can assume it. Dispatching the deploy from
another branch will (intentionally) fail with AccessDenied. To allow environments or tags,
widen the `sub` condition in `data.tf` / `oidc.tf`.

## Deploy needs the ECS stack up

The deploy targets the (billable) `infra/ecs` cluster/service. Apply `infra/ecs` first,
run the deploy, then **destroy ecs at session end**. The OIDC role here stays put.
