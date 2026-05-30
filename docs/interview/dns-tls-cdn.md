# DNS / TLS / CDN (Route 53 + ACM + CloudFront)

> To be filled in after Phase 8.

**Question as asked:** "Set up DNS with routes, end to end."

**60-second answer:** _(fill in)_

**Cover:**
- Route 53 hosted zone; record types (A/AAAA alias, CNAME, NS, TXT); TTLs.
- Alias records vs CNAME (apex can't CNAME → use alias).
- ACM cert + DNS validation; CloudFront certs must be in `us-east-1`.
- CloudFront: origins, cache behaviors, OAC, HTTP→HTTPS redirect; what to cache for a
  dynamic app vs static assets.
- Request path: user → Route 53 → CloudFront → ALB → ECS task.

**Hands-on notes:** _(fill in)_
