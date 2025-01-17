##############################################################################
# Terraform Providers
##############################################################################

terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      # Atracker needs to have the v2 API
      version = "1.49.0"
    }
    external = {
      source  = "hashicorp/external"
      version = ">= 2.2.3"
    }
  }
  required_version = ">= 1.3.0"
}

##############################################################################
