# --- Security groups ---
# ALB SG: open :80 to the world (this is the internet-facing entry point).
resource "aws_security_group" "alb" {
  name        = "${local.name}-alb"
  description = "ALB ingress from the internet on :80"
  vpc_id      = local.vpc_id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${local.name}-alb" }
}

# Task SG: only the ALB may reach the container port. Nothing else can talk to the tasks,
# even though they have public IPs (public IP is only for ECR pull egress, not ingress).
resource "aws_security_group" "task" {
  name        = "${local.name}-task"
  description = "Allow ALB to reach the Tasklet container port"
  vpc_id      = local.vpc_id

  ingress {
    description     = "App port from the ALB only"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "All outbound (ECR pull, CloudWatch logs)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${local.name}-task" }
}

# --- Application Load Balancer ---
resource "aws_lb" "main" {
  name               = local.name
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb.id]
  subnets            = local.public_subnets
}

# Target group: ip target type (required for Fargate, since tasks register by ENI IP).
# Health check hits the app's liveness endpoint; unhealthy targets are pulled from rotation.
resource "aws_lb_target_group" "app" {
  name        = local.name
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = local.vpc_id
  target_type = "ip"

  health_check {
    path                = "/healthz"
    matcher             = "200"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  # Short drain time so destroys/redeploys are quick in the dojo.
  deregistration_delay = 10
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
