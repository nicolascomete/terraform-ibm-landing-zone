##############################################################################
# VPN Gateway Locals
##############################################################################

locals {
  vpn_gateway_map    = module.dynamic_values.vpn_gateway_map
  vpn_connection_map = module.dynamic_values.vpn_connection_map
}

##############################################################################
    
    
resource "ibm_is_ike_policy" "ike_policy" {
  for_each                 =  {for k, v in local.vpn_connection_map : k => v if lookup(v, "ike_policy", null) != null }
  name                     = "${var.prefix}-${each.key}"
  #resource_group           = ibm_is_vpn_gateway.gateway[each.value.gateway_name].id
  
  authentication_algorithm = each.value.ike_policy.authentication_algorithm
  encryption_algorithm     = each.value.ike_policy.encryption_algorithm
  dh_group                 = each.value.ike_policy.dh_group 
  ike_version              = each.value.ike_policy.ike_version
}

/*resource "ibm_is_ipsec_policy" "ipsec_policy" {
  name                     = "${var.prefix}-${var.vpc_workload.prefix}-ipsec-policy"
  resource_group           = data.ibm_resource_group.resource_group.id
  authentication_algorithm = var.vpc_management_vpn_s2s.phase2.authentication_algorithm
  encryption_algorithm     = var.vpc_management_vpn_s2s.phase2.encryption_algorithm
  pfs                      = "disabled"
}*/



##############################################################################
# Create VPN Gateways
##############################################################################

resource "ibm_is_vpn_gateway" "gateway" {
  for_each       = local.vpn_gateway_map
  name           = "${var.prefix}-${each.key}"
  subnet         = each.value.subnet_id
  mode           = each.value.mode
  resource_group = each.value.resource_group == null ? null : local.resource_groups[each.value.resource_group]
  tags           = var.tags

  timeouts {
    delete = "1h"
  }
}

resource "ibm_is_vpn_gateway_connection" "gateway_connection" {
  for_each       = local.vpn_connection_map
  name           = each.value.connection_name
  vpn_gateway    = ibm_is_vpn_gateway.gateway[each.value.gateway_name].id
  peer_address   = each.value.peer_address
  preshared_key  = each.value.preshared_key
  local_cidrs    = each.value.local_cidrs
  peer_cidrs     = each.value.peer_cidrs
  admin_state_up = each.value.admin_state_up
}

##############################################################################
