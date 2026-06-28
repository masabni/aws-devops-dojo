# --- ECS task EXECUTION role ---
# Used by the ECS agent (not your app code) to pull the image from ECR and ship
# container logs to CloudWatch. This is distinct from the *task role* (which grants
# permissions to your application — we'll add one in Phase 5 for DynamoDB access).
data "aws_iam_policy_document" "ecs_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "execution" {
  name               = "${local.name}-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
}

# AWS-managed policy that grants exactly the ECR-pull + CloudWatch-logs perms the
# execution role needs. Using the managed policy is the documented best practice.
resource "aws_iam_role_policy_attachment" "execution" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# --- ECS TASK role (Phase 5) ---
# Used by the APPLICATION code at runtime (the SDK calls DynamoDB with these creds),
# as opposed to the EXECUTION role above (used by the ECS agent to pull the image and
# ship logs). Keeping them separate is the whole point: the platform's permissions and
# the app's permissions have different blast radii. Same trust (ecs-tasks) as execution.
resource "aws_iam_role" "task" {
  name               = "${local.name}-task"
  assume_role_policy = data.aws_iam_policy_document.ecs_assume.json
}

# Least-privilege: only the CRUD actions the DynamoStore actually issues, scoped to the
# single Tasklet table. (No Query/UpdateItem yet — add them when an access pattern needs
# them, not before.)
data "aws_iam_policy_document" "task_dynamodb" {
  statement {
    sid = "TaskletTableAccess"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:Scan",
    ]
    resources = [local.table_arn]
  }
}

resource "aws_iam_role_policy" "task_dynamodb" {
  name   = "${local.name}-dynamodb"
  role   = aws_iam_role.task.id
  policy = data.aws_iam_policy_document.task_dynamodb.json
}
