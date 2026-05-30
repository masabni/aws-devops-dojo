# infra/dns — Phase 8 (stub)

Route 53 hosted zone + ACM cert (us-east-1 for CloudFront) + CloudFront distribution
fronting the ALB. See `docs/phases/phase-8-dns-tls-cdn.md`.

Hosted zone ~$0.50/mo; domain is an annual fee. **Destroy the ALB/ECS origin at session end.**
