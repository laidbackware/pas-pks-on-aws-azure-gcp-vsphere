locals {
  stable_config = {
    environment_name = var.env_name
    
    nsxt_host     = var.nsxt_host
    # nsxt_username = var.nsxt_username
    # nsxt_password = var.nsxt_password
    # nsxt_ca_cert  = var.nsxt_ca_cert

    # vcenter_datacenter    = var.vcenter_datacenter
    # vcenter_datastore     = var.vcenter_datastore
    # vcenter_host          = var.vcenter_host
    # vcenter_username      = var.vcenter_username
    # vcenter_password      = var.vcenter_password
    # vcenter_resource_pool = var.vcenter_resource_pool
    # vcenter_cluster       = var.vcenter_cluster

    # ops_manager_ntp             = var.ops_manager_ntp
    # ops_manager_dns             = var.ops_manager_dns
    # ops_manager_dns_servers     = var.ops_manager_dns_servers
    # ops_manager_folder          = var.ops_manager_folder
    # ops_manager_ssh_public_key  = tls_private_key.ops-manager.public_key_openssh
    # ops_manager_ssh_private_key = tls_private_key.ops-manager.private_key_pem
    ops_manager_public_ip       = "${cidrhost(var.infrastructure_cidr, 2)}"

    management_subnet_name               = nsxt_logical_switch.infrastructure-ls.display_name
    management_subnet_cidr               = var.infrastructure_cidr
    management_subnet_netmask        = "${cidrnetmask(var.infrastructure_cidr)}"
    management_subnet_gateway        = "${cidrhost(var.infrastructure_cidr, 1)}"
    management_subnet_reserved_ip_ranges = "${cidrhost(var.infrastructure_cidr, 1)}-${cidrhost(var.infrastructure_cidr, 2)}"

    # pas_subnet_name               = nsxt_logical_switch.infrastructure_ls.display_name
    # pas_subnet_cidr               = "${var.subnet_prefix}.1.0/24"
    # pas_subnet_gateway            = "${var.subnet_prefix}.0.1"
    # pas_subnet_reserved_ip_ranges = ""

    pas_subnet_name               = nsxt_logical_switch.pas-deployment-ls.display_name
    pas_subnet_cidr               = var.deployment_cidr
    pas_subbet_netmask        = "${cidrnetmask(var.deployment_cidr)}"
    pas_subnet_gateway        = "${cidrhost(var.deployment_cidr, 1)}"
    pas_subnet_reserved_ip_ranges = ""

    # allow_unverified_ssl      = var.allow_unverified_ssl
    # disable_ssl_verification  = !var.allow_unverified_ssl

    lb_pool_web = nsxt_lb_pool.pas-web-pool.display_name
    lb_pool_tcp = nsxt_lb_pool.pas-tcp-pool.display_name
    lb_pool_ssh = nsxt_lb_pool.pas-ssh-pool.display_name

    # Shared
    tier_0_id = data.nsxt_logical_tier0_router.t0-router.id

    #PKS Section
    pks_pods_ip_block_id = nsxt_ip_block.pks-pod-ip-block.id
    pks_nodes_ip_block_id = nsxt_ip_block.pks-node-ip-block.id
    pks_floating_ip_pool_id = nsxt_ip_pool.pks-external-ip-pool.id

    # PAS Section
    transport_zone_id = data.nsxt_transport_zone.overlay-transport-zone.id

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


# Shared Section
# output "opsman_ip" {
#     value = "${cidrhost(var.infrastructure_cidr, 2)}"
# }

# output "infra_network_gateway" {
#     value = "${cidrhost(var.infrastructure_cidr, 1)}"
# }

# output "infra_network_cidr" {
#     value = "${var.infrastructure_cidr}"
# }

# output "infra_network_netmask" {
#     value = "${cidrnetmask(var.infrastructure_cidr)}"
# }

# output "infra_network_name" {
#     value = "${nsxt_logical_switch.pas_infrastructure_ls.display_name}"
# }

# output "nsxt_manager_ip" {
#     value = "${var.nsxt_host}"
# }

# output "nsxt_username" {
#     value = "${var.nsxt_username}"
# }

# output "tier_0_id" {
#     value = "${data.nsxt_logical_tier0_router.t0_router.id}"
# }


# PKS Section
# output "pks_pods_ip_block_id" {
#     value = "${nsxt_ip_block.pks_pod_ip_block.id}"
# }

# output "pks_nodes_ip_block_id" {
#     value = "${nsxt_ip_block.pks_node_ip_block.id}"
# }

# output "pks_floating_ip_pool_id" {
#     value = "${nsxt_ip_pool.pks_external_ip_pool.id}"
# }

# PAS Section
# output "transport_zone_id" {
#     value = "${data.nsxt_transport_zone.overlay_transport_zone.id}"
# }

# Control Plane Section
# output "plane_network_gateway" {
#     value = "${cidrhost(var.plane_cidr, 1)}"
# }

# output "plane_network_cidr" {
#     value = "${var.plane_cidr}"
# }

# output "plane_network_netmask" {
#     value = "${cidrnetmask(var.plane_cidr)}"
# }

# output "plane_network_name" {
#     value = "${nsxt_logical_switch.plane_ls.display_name}"
# }