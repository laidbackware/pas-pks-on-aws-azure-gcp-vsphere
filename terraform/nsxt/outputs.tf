locals {
  stable_config = {
    environment_name = var.env_name
    
    nsxt_host     = var.nsxt_host

    ops_manager_public_ip       = "${cidrhost(var.infrastructure_cidr, 2)}"

    management_subnet_name               = nsxt_policy_segment.mgmt_segment.display_name
    management_subnet_cidr               = var.infrastructure_cidr
    management_subnet_netmask        = cidrnetmask(var.infrastructure_cidr)
    management_subnet_gateway        = cidrhost(var.infrastructure_cidr, 1)
    management_subnet_reserved_ip_ranges = "${cidrhost(var.infrastructure_cidr, 1)}-${cidrhost(var.infrastructure_cidr, 2)}"



    deployment_subnet_name               = nsxt_policy_segment.deployment_segment.display_name
    deployment_subnet_cidr               = var.deployment_cidr
    deployment_subbet_netmask        = cidrnetmask(var.deployment_cidr)
    deployment_subnet_gateway        = cidrhost(var.deployment_cidr, 1)
    deployment_subnet_reserved_ip_ranges = ""


    # lb_pool_web = nsxt_lb_pool.pas-web-pool.display_name
    # lb_pool_tcp = nsxt_lb_pool.pas-tcp-pool.display_name
    # lb_pool_ssh = nsxt_lb_pool.pas-ssh-pool.display_name

    # Shared
    tier_0_id = nsxt_policy_tier0_gateway.tier0_gw.id

    #PKS Section
    pks_pods_ip_block_id = nsxt_policy_ip_block.pks_pod_ip_block.id
    pks_nodes_ip_block_id = nsxt_policy_ip_block.pks_node_ip_block.id
    pks_floating_ip_pool_id = nsxt_policy_ip_pool.pks_external_ip_pool.id

    # PAS Section
    transport_zone_id = data.nsxt_policy_transport_zone.overlay_transport_zone.id
    pas_floating_ip_pool_id = nsxt_policy_ip_pool.pas_external_ip_pool.id
    pas_container_ip_block = nsxt_policy_ip_block.pas_container_ip_block.id

  }
}

output "stable_config" {
  value     = jsonencode(local.stable_config)
  sensitive = true
}

output "stable_config_yaml" {
  value     = yamlencode(local.stable_config)
  # sensitive = true
}

