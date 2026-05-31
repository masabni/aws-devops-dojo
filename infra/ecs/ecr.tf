# ECR repository for the Tasklet image. ECS pulls from here on every task start.
resource "aws_ecr_repository" "app" {
  name                 = var.app_name
  image_tag_mutability = "MUTABLE" # dojo: we re-push tags like "v1" while iterating
  force_delete         = true      # so `terraform destroy` removes the repo even if images remain

  image_scanning_configuration {
    scan_on_push = true # free basic CVE scan — good habit to practice
  }
}

# Keep ECR storage near $0: only retain the 5 most recent images, expire the rest.
resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the last 5 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 5
        }
        action = { type = "expire" }
      }
    ]
  })
}
