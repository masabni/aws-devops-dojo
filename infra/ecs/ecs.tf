# CloudWatch log group for the container's stdout/stderr.
resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${local.name}"
  retention_in_days = var.log_retention_days
}

resource "aws_ecs_cluster" "main" {
  name = local.name

  setting {
    name  = "containerInsights"
    value = "disabled" # Container Insights bills per metric; keep off for the dojo.
  }
}

# Task definition: one Tasklet container on Fargate.
resource "aws_ecs_task_definition" "app" {
  family                   = local.name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc" # required by Fargate; each task gets its own ENI
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.execution.arn
  # Phase 5: the app now calls DynamoDB, so it gets a task role (its own AWS identity).
  task_role_arn = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name      = var.app_name
      image     = local.container_image
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]
      environment = [
        { name = "PORT", value = tostring(var.container_port) },
        { name = "NODE_ENV", value = "production" },
        { name = "APP_VERSION", value = var.image_tag },
        # Phase 5: switch the app to the shared DynamoDB store.
        { name = "STORE_BACKEND", value = "dynamodb" },
        { name = "TASKS_TABLE_NAME", value = local.table_name },
        { name = "AWS_REGION", value = var.region }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.app.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "app" {
  name            = local.name
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  # Tasks run in the PUBLIC subnets with a public IP so they can pull from ECR without
  # a NAT gateway (NAT is ~$32/mo — kept off in foundation for cost safety).
  network_configuration {
    subnets          = local.public_subnets
    security_groups  = [aws_security_group.task.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name   = var.app_name
    container_port   = var.container_port
  }

  # Give a new task time to pass health checks before ECS counts it against the service.
  health_check_grace_period_seconds = 30

  # Don't fight the ALB: wait for the listener before creating the service.
  depends_on = [aws_lb_listener.http]

  # Let other owners drive two fields so `terraform apply` doesn't fight them:
  #   - desired_count: owned by Application Auto Scaling (Phase 3, autoscaling.tf).
  #   - task_definition: owned by the CI/CD pipeline (Phase 4). The deploy workflow
  #     registers new task-def revisions (new image SHA) and points the service at
  #     them; ignoring it stops apply from reverting to the var.image_tag baseline.
  # Both here are just the INITIAL value at creation time.
  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }
}
