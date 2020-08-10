data "nsxt_policy_edge_cluster" "edge_cluster" {
  display_name = var.nsxt_edge_cluster_name
}

data "nsxt_policy_transport_zone" "overlay_transport_zone" {
  display_name = var.overlay_transport_zone_name
}

resource "nsxt_policy_tier0_gateway" "tier0_gw" {
  description               = "Tier-0 provisioned by Terraform"
  display_name              = "tier0-gw"
#   nsx_id                    = "predefined_id"
  failover_mode             = "PREEMPTIVE"
  enable_firewall           = true
  ha_mode                   = "ACTIVE_STANDBY"
  edge_cluster_path         = data.nsxt_policy_edge_cluster.edge_cluster.path
}