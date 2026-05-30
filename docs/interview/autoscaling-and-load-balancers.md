# Autoscaling + load balancers

> To be filled in after Phase 3.

**Question as asked:** "How do you set up autoscaling and a load balancer?"

**60-second answer:** _(fill in)_

**Cover:**
- ALB: listeners, target groups, health checks, deregistration delay (connection draining).
- ALB vs NLB vs (legacy) CLB — when each.
- Target-tracking vs step vs scheduled scaling; the metric (CPU / request-count-per-target).
- Why scale-in is slower than scale-out (flap avoidance); cooldowns; min/max capacity.
- How ALB + autoscaling + health checks combine for zero-downtime deploys.

**Hands-on notes:** _(what the scale-out/in actually looked like driving `/loadtest`)_
