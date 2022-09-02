terraform {
  required_providers {
    cyral = {
      source  = "cyralinc/cyral"
      version = ">= 2.8.0"
    }
  }

  # We are using Terraform Cloud to manage the Terraform state. Please replace
  # the organization name with your own Terraform Cloud organization. For more
  # information, see the "Prerequisites" section of the README.
  cloud {
    organization = "REPLACE_ME"
    workspaces {
      name = "cyral-quickstart-terraform"
    }
  }
}

variable "cyral_control_plane" {
  type        = string
  description = "Cyral Control Plane in the format <host>:<port>, e.g. tenant.cyral.com:443"
}

variable "cyral_client_id" {
  type        = string
  description = "Cyral service account client ID"
}

variable "cyral_client_secret" {
  type        = string
  description = "Cyral service account client secret"
}

# Configures the Cyral Terraform provider, which is used to created resources
# within the Cyral Control Plane.
provider "cyral" {
  control_plane = var.cyral_control_plane
  client_id     = var.cyral_client_id
  client_secret = var.cyral_client_secret
}

# Creates an example (i.e. non-functional) PostgreSQL data repository to be
# tracked by Cyral (https://cyral.com/docs/manage-repositories/repo-track).
# Feel free to modify this to create any real repositories you want to protect
# with Cyral.
resource "cyral_repository" "example-pg" {
  name = "example-pg"
  type = "postgresql"
  host = "postgres.example.com"
  port = 5432
}

# Creates NAME and DOB data labels. Labels are short names for data
# locations (like a table, collection, or S3 bucket) that you want to protect.
# Data labels are used in the "data map", where specific data locations (e.g. a
# specific column in a specific database) are mapped to labels. Therefore,
# labels can be thought of as the are the building blocks of the "data map"
# (see below), which is used to identify which specific data policies apply to.
resource "cyral_datalabel" "NAME" {
  name        = "NAME"
  description = "Customer name"
  tags        = ["PII"]
}

resource "cyral_datalabel" "DOB" {
  name        = "DOB"
  description = "Customer date of birth"
  tags        = ["PII"]
}

# Creates a data map for the example Postgres repository. In this example, we
# map the columns "first_name" and "last_name" (in the "customer" table, in
# the "finance" schema) to the NAME label, and the "date_of_birth" column (in
# the same table/schema) to the DOB label. The equivalent YAML representation
# is:
#
# NAME:
#   attributes:
#     - finance.customers.first_name
#     - finance.customers.last_name
# DOB:
#   attributes:
#     - finance.customers.date_of_birth
#
resource "cyral_repository_datamap" "example-pg_datamap" {
  repository_id = cyral_repository.example-pg.id

  mapping {
    label      = cyral_datalabel.NAME.name
    attributes = [
      "finance.customers.first_name",
      "finance.customers.last_name"
    ]
  }

  mapping {
    label      = cyral_datalabel.DOB.name
    attributes = [
      "finance.customers.date_of_birth",
    ]
  }
}

# Creates a Cyral policy named "PII Policy". Policies and their rules are
# treated as separate resources in the Cyral API and Terraform. This resource
# creates the policy itself, and the rules are created separately. The policy
# is defined to manage the NAME and DOB data labels, and thus will apply to any
# actions on data mapped to those labels in the data map.
resource "cyral_policy" "pii_policy" {
  name        = "PII Policy"
  description = "Personal identifiable information policy"
  enabled     = true
  data        = [
    cyral_datalabel.NAME.name,
    cyral_datalabel.DOB.name
  ]
}

# Creates a single "default" rule for the policy defined above. In this
# example, the rule restricts all reads to 10 rows, and deletes and updates to
# a single row at a time. The equivalent YAML representation is:
#
# data:
#  - NAME
#  - DOB
# rules:
#  - reads:
#      - data: any
#        rows: 10
#        severity: low
#    updates:
#      - data: any
#        rows: 1
#        severity: medium
#    deletes:
#      - data: any
#        rows: 1
#        severity: high
#
resource "cyral_policy_rule" "pii_policy_default_rule" {
  policy_id = cyral_policy.pii_policy.id

  reads {
    data     = ["*"]
    rows     = 10
    severity = "low"
  }

  updates {
    data     = ["*"]
    rows     = 1
    severity = "medium"
  }

  deletes {
    data     = ["*"]
    rows     = 1
    severity = "high"
  }
}
