data "nsxt_policy_edge_cluster" "edge_cluster" {
  display_name = var.nsxt_edge_cluster_name
}

data "nsxt_policy_transport_zone" "overlay_transport_zone" {
  display_name = var.overlay_transport_zone_name
}

data "nsxt_policy_transport_zone" "vlan_transport_zone" {
  display_name = var.vlan_transport_zone_name
}

resource "nsxt_policy_tier0_gateway" "tier0_gw" {
  description               = "Tier-0 provisioned by Terraform"
  display_name              = "tier0-gw"
  failover_mode             = "PREEMPTIVE"
  enable_firewall           = true
  ha_mode                   = "ACTIVE_STANDBY"
  edge_cluster_path         = data.nsxt_policy_edge_cluster.edge_cluster.path
}

resource "nsxt_policy_static_route" "to_static)route" {
  display_name = "default_route"
  gateway_path = nsxt_policy_tier0_gateway.tier0_gw.path
  network      = "0.0.0.0/0"
  next_hop {
    admin_distance = "1"
    ip_address     = var.t0_static_route_next_hop
  }
}

resource "nsxt_policy_vlan_segment" "vlan_uplink_segment" {
  display_name        = "t0-uplink-segment"
  description         = "Terraform provisioned VLAN Segment"
  transport_zone_path = data.nsxt_policy_transport_zone.vlan_transport_zone.path
  vlan_ids            = ["0"]
}

resource "nsxt_policy_tier0_gateway_interface" "t0_up" {
  display_name           = "t0_interface"
  description            = "Terraform provisioned interface"
  type                   = "EXTERNAL"
  gateway_path           = nsxt_policy_tier0_gateway.tier0_gw.path
  segment_path           = nsxt_policy_vlan_segment.vlan_uplink_segment.path
  subnets                = [var.nsxt_t0_router_uplink_ip]
  mtu                    = 1500
}

resource "nsxt_policy_tier1_gateway" "tier1_gw_platform" {
  description               = "Tier-1 provisioned by Terraform"
  display_name              = "tier1-gw-platform"
  edge_cluster_path         = data.nsxt_policy_edge_cluster.edge_cluster.path
  failover_mode             = "PREEMPTIVE"
  enable_firewall           = "true"
  tier0_path                =  nsxt_policy_tier0_gateway.tier0_gw.path
  route_advertisement_types = ["TIER1_STATIC_ROUTES", "TIER1_CONNECTED", "TIER1_NAT", "TIER1_LB_VIP", "TIER1_LB_SNAT"]
  pool_allocation           = "LB_SMALL"
}

resource "nsxt_policy_segment" "mgmt_segment" {
    display_name        = "platform-management-segment"
    description         = "Terraform provisioned Segment"
    transport_zone_path = data.nsxt_policy_transport_zone.overlay_transport_zone.path
    connectivity_path = nsxt_policy_tier1_gateway.tier1_gw_platform.path

    subnet {
      cidr        = "${cidrhost(var.infrastructure_cidr, 1)}/${substr(var.infrastructure_cidr, -2, 2)}"
    }
}

resource "nsxt_policy_segment" "deployment_segment" {
    display_name        = "platform-deployment-segment"
    description         = "Terraform provisioned Segment"
    transport_zone_path = data.nsxt_policy_transport_zone.overlay_transport_zone.path
    connectivity_path = nsxt_policy_tier1_gateway.tier1_gw_platform.path

    subnet {
      cidr        = "${cidrhost(var.deployment_cidr, 1)}/${substr(var.deployment_cidr, -2, 2)}"
    }
}

resource "nsxt_policy_segment" "services_segment" {
    display_name        = "platform-services-segment"
    description         = "Terraform provisioned Segment"
    transport_zone_path = data.nsxt_policy_transport_zone.overlay_transport_zone.path
    connectivity_path = nsxt_policy_tier1_gateway.tier1_gw_platform.path

    subnet {
      cidr        = "${cidrhost(var.services_cidr, 1)}/${substr(var.services_cidr, -2, 2)}"
    }
}

# Pools and blocks

resource "nsxt_policy_ip_pool" "pas_external_ip_pool" {
  display_name = "pas-external-ip-pool"
}

resource "nsxt_policy_ip_pool_static_subnet" "pas_external_ip_pool_subnet" {
  display_name        = "pas-external-ip-pool-subnet"
  pool_path           = nsxt_policy_ip_pool.pas_external_ip_pool.path
  cidr                = var.pas_external_ip_pool_cidr
  allocation_range {
    start = cidrhost(var.pas_external_ip_pool_cidr, 1)
    end   = cidrhost(var.pas_external_ip_pool_cidr, -5)
  }
}

resource "nsxt_policy_ip_pool" "pks_external_ip_pool" {
  display_name = "pks-external-ip-pool"
}

resource "nsxt_policy_ip_pool_static_subnet" "pks_external_ip_pool_subnet" {
  display_name        = "pks-external-ip-pool-subnet"
  pool_path           = nsxt_policy_ip_pool.pks_external_ip_pool.path
  cidr                = var.pks_external_ip_pool_cidr
  allocation_range {
    start = cidrhost(var.pks_external_ip_pool_cidr, 1)
    end   = cidrhost(var.pks_external_ip_pool_cidr, -2)
  }
}

resource "nsxt_policy_ip_block" "pas_container_ip_block" {
  display_name = "pas-container-block"
  description  = "PAS subnets are allocated from this pool to each newly-created Org"
  cidr         = var.pas_container_ip_block_cidr
}

resource "nsxt_policy_ip_block" "pks_node_ip_block" {
  display_name = "pks-node-block"
  description  = "PKS subnets are allocated from this pool to each newly-created K8S cluster"
  cidr         = var.pks_node_ip_block_cidr
}

resource "nsxt_policy_ip_block" "pks_pod_ip_block" {
  display_name = "pks-pod-block"
  description  = "PKS subnets are allocated from this pool to each newly-created K8s Namespace"
  cidr         = var.pks_pod_ip_block_cidr
}