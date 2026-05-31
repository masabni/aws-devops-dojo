# ============================================================================
# Phase 3 — Application Auto Scaling for the ECS service
# ============================================================================
# Two resources: (1) register the service's task count as a "scalable target"
# with min/max bounds, then (2) attach a target-tracking policy that moves the
# count to keep CPU near a setpoint. AWS auto-manages the CloudWatch alarms.

# (1) SCALABLE TARGET — "this knob can be scaled, between min and max".
# resource_id encodes WHICH thing: service/<cluster-name>/<service-name>.
# scalable_dimension says WHICH attribute of it: the service's DesiredCount.
resource "aws_appautoscaling_target" "ecs" {
  service_namespace  = "ecs"
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  min_capacity = var.min_capacity
  max_capacity = var.max_capacity
}

# (2) SCALING POLICY — target tracking on average CPU.
# Think "thermostat": AWS creates hidden CloudWatch alarms that add tasks when
# CPU runs hot and remove them when it cools, aiming to hold target_value.
resource "aws_appautoscaling_policy" "cpu" {
  name               = "${local.name}-cpu-target-tracking"
  policy_type        = "TargetTrackingScaling"
  service_namespace  = aws_appautoscaling_target.ecs.service_namespace
  resource_id        = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension

  target_tracking_scaling_policy_configuration {
    # Predefined metric = average CPU across all tasks in the service.
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = var.cpu_target_percent # hold avg CPU near this %
    scale_out_cooldown = var.scale_out_cooldown # add capacity fast
    scale_in_cooldown  = var.scale_in_cooldown  # remove capacity slowly (anti-flapping)
  }
}
