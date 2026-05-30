# DynamoDB vs Aurora — which DB when

> To be filled in after Phase 7, from modeling the same Tasklet data both ways.

**Question as asked:** "When do you choose DynamoDB vs Aurora (relational)?"

**60-second answer:** _(fill in)_

**Decision checklist:**
- Known, key-based access patterns → DynamoDB. Ad-hoc queries / joins / transactions → Aurora.
- Horizontal serverless scale + single-digit-ms at any size → DynamoDB.
- Rich relational integrity, secondary indexes, SQL analytics → Aurora.
- Cost shape: per-request (DynamoDB on-demand) vs ACU/hours (Aurora, has idle cost).
- Schema flexibility vs enforced schema.

**Hands-on notes:** _(fill in — what was awkward modeling tasks each way)_
