terraform {
  required_providers {
    restapi = {
      source  = "Mastercard/restapi"
      version = "1.17.0"
    }
    ibm = {
      source = "IBM-Cloud/ibm"
    }
  }
}

# Get IBM IAM Auth Token to retrieve IAM Access Token
data "ibm_iam_auth_token" "tokendata" {}

# Variables

variable "kms_url" {
  type = string
}

variable "instance_id" {
  type = string
}

variable "key_ring_id" {
  type = string
}

# Resources

provider "restapi" {
  uri = var.kms_url
  debug                 = true
  write_returns_object  = false
  create_returns_object = false
  headers = {
    "authorization"    = data.ibm_iam_auth_token.tokendata.iam_access_token
    "bluemix-instance" = var.instance_id
  }
}

resource "restapi_object" "key_ring" {
  object_id = var.key_ring_id

  debug = true
  path = "/api/v2/key_rings"
  create_path = "/api/v2/key_rings/{id}"
  read_path = "/api/v2/key_rings"

  id_attribute = "api/v2/key_rings"
  read_search = {
    "results_key" = "resources"
    "search_key" = "id"
  }
  data = ""
}

# Outputs

output key_ring_id {
  value = restapi_object.key_ring.id
}
