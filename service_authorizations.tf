##############################################################################
# Service To Service Authorization Policies
# > `target_resource_group_id` and `target_resource_instance_id` are mutually
#    exclusive. IAM will use the least specific of the two
##############################################################################

locals {
  # authorization_policies = var.another_slz_exists_in_account ? module.dynamic_values.service_authorizations : v if contains(["Allow block storage volumes to be encrypted by KMS instance"], v.description)]) : module.dynamic_values.service_authorizations
  authorization_policies = var.another_slz_exists_in_account ? { for k,v in module.dynamic_values.service_authorizations : k => v } : module.dynamic_values.service_authorizations
}

##############################################################################


##############################################################################
# Authorization Policies
##############################################################################

resource "ibm_iam_authorization_policy" "policy" {
  for_each                    = local.authorization_policies
  source_service_name         = each.value.source_service_name
  source_resource_type        = lookup(each.value, "source_resource_type", null)
  source_resource_instance_id = lookup(each.value, "source_resource_instance_id", null)
  source_resource_group_id    = lookup(each.value, "source_resource_group_id", null)
  target_service_name         = each.value.target_service_name
  target_resource_instance_id = lookup(each.value, "target_resource_instance_id", null)
  target_resource_group_id    = lookup(each.value, "target_resource_group", null)
  roles                       = each.value.roles
  description                 = each.value.description
}

##############################################################################
