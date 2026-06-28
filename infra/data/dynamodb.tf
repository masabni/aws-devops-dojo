# ============================================================================
# Phase 5 — DynamoDB single-table store for Tasklet
# ============================================================================
# One table holds all of the app's data (single-table design). For Tasklet's only
# entity so far, each task is one item keyed by PK = "TASK#<id>".
#
# Access patterns today:
#   - get/put/update/delete a task by id  -> direct key op on PK (cheap, O(1))
#   - list all tasks                      -> Scan (reads the whole table)
# Scan is an ANTI-PATTERN at scale (cost + latency grow with table size), but fine
# at dojo scale. At real scale you'd add a fixed partition + sort key (Query one
# partition) or a GSI to list without scanning. See DynamoStore for the same note.

locals {
  table_name = "${var.project}-${var.app_name}"
}

resource "aws_dynamodb_table" "app" {
  name = local.table_name

  # On-demand: no capacity planning, pay per request. ≈ $0 at dojo traffic and
  # nothing to scale or tear down. (Provisioned would need RCU/WCU sizing + alarms.)
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "PK" # partition key; no sort key (one item per partition)

  attribute {
    name = "PK"
    type = "S"
  }

  # PITR = continuous backups, restore to any second in the last 35 days. Pennies
  # at this size and a good habit to practice for anything that holds real data.
  point_in_time_recovery {
    enabled = true
  }
}
