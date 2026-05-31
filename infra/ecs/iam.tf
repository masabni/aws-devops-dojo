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
