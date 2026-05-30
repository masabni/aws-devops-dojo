# Phase 8 — DNS / TLS / CDN

**Goal:** put a real domain, HTTPS, and a CDN in front of Tasklet — end to end.

## Build (`infra/dns/`)
- Register / use a domain; Route 53 **hosted zone**.
- **ACM** certificate (DNS-validated via Route 53 records). Note: CloudFront certs must be
  in `us-east-1`.
- **CloudFront** distribution with the ALB as origin; redirect HTTP→HTTPS.
- Route 53 **alias A/AAAA** record → CloudFront.

## Interview angle → `docs/interview/dns-tls-cdn.md`
- Hosted zones, record types (A/AAAA alias, CNAME, NS), TTLs.
- ACM + DNS validation; why CloudFront certs live in us-east-1.
- CloudFront caching, origins, OAC; what to cache vs pass through for a dynamic app.
- Alias records vs CNAME at the apex.

## Cost note
Domain registration is a small annual fee; hosted zone ~$0.50/mo; CloudFront/ACM cheap at
this scale. **Destroy the ALB/ECS origin at session end** (the zone can stay).
