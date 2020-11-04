# Data {
data "nsxt_edge_cluster" "edge-cluster" {
  display_name = var.nsxt_edge_cluster_name
}

data "nsxt_transport_zone" "overlay-transport-zone" {
  display_name = var.overlay_transport_zone_name
}

# }

#Tier-0 Router Config {
data "nsxt_logical_tier0_router" "t0-router" {
  display_name = var.nsxt_t0_router_name
}

# resource "nsxt_logical_tier0_router" "t0_router" {
#   display_name           = "T0-Router"
#   description            = "ACTIVE-STANDBY Tier0 router provisioned by Terraform"
#   high_availability_mode = "ACTIVE_STANDBY"
#   edge_cluster_id        = "${data.nsxt_edge_cluster.edge-cluster.id}"

#   tag {
#     scope = "color"
#     tag   = "blue"
#   }
# }

resource "nsxt_logical_router_link_port_on_tier0" "t0-to-t1-infrastructure" {
  display_name = "T0-to-T1-PAS-Infrastructure"

  description       = "Link Port on Logical Tier 0 Router for connecting to Tier 1 Infrastructure Router."
  logical_router_id = data.nsxt_logical_tier0_router.t0-router.id

  tag {
    scope = "terraform"
    tag   = var.env_name
  }
}
resource "nsxt_logical_router_link_port_on_tier0" "t0-to-t1-pas-deployment" {
  display_name = "T0-to-T1-PAS-Deployment"

  description       = "Link Port on Logical Tier 0 Router for connecting to Tier 1 Deployment Router."
  logical_router_id = data.nsxt_logical_tier0_router.t0-router.id

  tag {
    scope = "terraform"
    tag   = var.env_name
  }
}

resource "nsxt_logical_router_link_port_on_tier0" "t0-to-t1-services" {
  display_name = "T0-to-T1-PAS-Services"

  description       = "Link Port on Logical Tier 0 Router for connecting to Tier 1 Infrastructure Router."
  logical_router_id = data.nsxt_logical_tier0_router.t0-router.id

  tag {
    scope = "terraform"
    tag   = var.env_name
  }
}

resource "nsxt_logical_router_link_port_on_tier0" "t0-to-t1-plane" {
  display_name = "T0-to-T1-Plane"

  description       = "Link Port on Logical Tier 0 Router for connecting to Tier 1 Control Plane Router."
  logical_router_id = data.nsxt_logical_tier0_router.t0-router.id

  tag {
    scope = "terraform"
    tag   = var.env_name
  }
}

# Tier-1 Router (PAS Infrastructure) {
resource "nsxt_logical_tier1_router" "t1-infrastructure" {
  display_name = "T1-Router-PAS-Infrastructure"

  description     = "PAS Infrastructure Tier 1 Router."

  enable_router_advertisement = true
  advertise_connected_routes  = true

  tag {
    scope = "terraform"
    tag   = var.env_name
  }
}

resource "nsxt_logical_router_link_port_on_tier1" "t1-infrastructure-to-t0" {
  display_name = "T1-PAS-Infrastructure-to-T0"

  description                   = "Link Port on Infrastructure Tier 1 Router connecting to Logical Tier 0 Router. Provisioned by Terraform."
  logical_router_id             = nsxt_logical_tier1_router.t1-infrastructure.id
  linked_logical_router_port_id = nsxt_logical_router_link_port_on_tier0.t0-to-t1-infrastructure.id

  tag {
    scope = "terraform"
    tag   = var.env_name
  }
}

resource "nsxt_logical_switch" "infrastructure-ls" {
  display_name = "PAS-Infrastructure"

  transport_zone_id = data.nsxt_transport_zone.overlay-transport-zone.id
  admin_state       = "UP"

  description      = "Logical Switch for the T1 Infrastructure Router."
  replication_mode = "MTEP"

  tag {
    scope = "terraform"
    tag   = var.env_name
  }
}

resource "nsxt_logical_port" "infrastructure-lp" {
  display_name = "PAS-Infrastructure-lp"

  admin_state       = "UP"
  description       = "Logical Port on the Logical Switch for the T1 Infrastructure Router."
  logical_switch_id = nsxt_logical_switch.infrastructure-ls.id

  tag {
    scope = "terraform"
    tag   = var.env_name
  }
}

resource "nsxt_logical_router_downlink_port" "infrastructure-dp" {
  display_name = "PAS-Infrastructure-dp"

  description                   = "Downlink port connecting PAS-Infrastructure router to its Logical Switch"
  logical_router_id             = nsxt_logical_tier1_router.t1-infrastructure.id
  linked_logical_switch_port_id = nsxt_logical_port.infrastructure-lp.id
  ip_address                    = "${cidrhost(var.infrastructure_cidr, 1)}/${substr(var.infrastructure_cidr, -2, 2)}"

  tag {
    scope = "terraform"
    tag   = var.env_name
  }
}
# }

# Tier-1 Router (PAS Deployment) {
resource "nsxt_logical_tier1_router" "t1-pas-deployment" {
  display_name = "T1-Router-PAS-Deployment"

  description     = "PAS Deployment Tier 1 Router."
  failover_mode   = "NON_PREEMPTIVE"
  edge_cluster_id = data.nsxt_edge_cluster.edge-cluster.id

  enable_router_advertisement = true
  advertise_connected_routes  = true
  advertise_lb_vip_routes     = true

  tag {
    scope = "terraform"
    tag   = var.env_name
  }
}

resource "nsxt_logical_router_link_port_on_tier1" "t1-pas-t1-pas-deployment" {
  display_name = "T1-Deployment-to-T0"

  description                   = "Link Port on Deployment Tier 1 Router connecting to Logical Tier 0 Router. Provisioned by Terraform."
  logical_router_id             = nsxt_logical_tier1_router.t1-pas-deployment.id
  linked_logical_router_port_id = nsxt_logical_router_link_port_on_tier0.t0-to-t1-pas-deployment.id

  tag {
    scope = "terraform"
    tag   = var.env_name
  }
}

resource "nsxt_logical_switch" "pas-deployment-ls" {
  display_name = "PAS-Deployment"

  transport_zone_id = data.nsxt_transport_zone.overlay-transport-zone.id
  admin_state       = "UP"

  description      = "Logical Switch for the T1 Deployment Router."
  replication_mode = "MTEP"

  tag {
    scope = "terraform"
    tag   = var.env_name
  }
}

resource "nsxt_logical_port" "pas-deployment-lp" {
  display_name = "PAS-Deployment-lp"

  admin_state       = "UP"
  description       = "Logical Port on the Logical Switch for the T1 Deployment Router."
  logical_switch_id = nsxt_logical_switch.pas-deployment-ls.id

  tag {
    scope = "terraform"
    tag   = var.env_name
  }
}

resource "nsxt_logical_router_downlink_port" "pas-deployment-dp" {
  display_name = "PAS-Deployment-dp"

  description                   = "Downlink port connecting PAS-Deployment router to its Logical Switch"
  logical_router_id             = nsxt_logical_tier1_router.t1-pas-deployment.id
  linked_logical_switch_port_id = nsxt_logical_port.pas-deployment-lp.id
  ip_address                    = "${cidrhost(var.deployment_cidr, 1)}/${substr(var.deployment_cidr, -2, 2)}"

  tag {
    scope = "terraform"
    tag   = var.env_name
  }
}
# }

# Tier-1 Router (PAS Services) {
resource "nsxt_logical_tier1_router" "t1-services" {
  display_name = "T1-Router-PAS-Services"

  description     = "PAS Services Tier 1 Router."
  failover_mode   = "NON_PREEMPTIVE"
  edge_cluster_id = data.nsxt_edge_cluster.edge-cluster.id

  enable_router_advertisement = true
  advertise_connected_routes  = true

  tag {
    scope = "terraform"
    tag   = var.env_name
  }
}

resource "nsxt_logical_router_link_port_on_tier1" "t1-services_to_t0" {
  display_name = "T1-Services-to-T0"

  description                   = "Link Port on Services Tier 1 Router connecting to Logical Tier 0 Router. Provisioned by Terraform."
  logical_router_id             = nsxt_logical_tier1_router.t1-services.id
  linked_logical_router_port_id = nsxt_logical_router_link_port_on_tier0.t0-to-t1-services.id

  tag {
    scope = "terraform"
    tag   = var.env_name
  }
}

resource "nsxt_logical_switch" "t1-services" {
  display_name = "PAS-Services"

  transport_zone_id = data.nsxt_transport_zone.overlay-transport-zone.id
  admin_state       = "UP"

  description      = "Logical Switch for the T1 Services Router."
  replication_mode = "MTEP"

  tag {
    scope = "terraform"
    tag   = var.env_name
  }
}

resource "nsxt_logical_port" "services-lp" {
  display_name = "PAS-Services-lp"

  admin_state       = "UP"
  description       = "Logical Port on the Logical Switch for the T1 Services Router."
  logical_switch_id = nsxt_logical_switch.t1-services.id

  tag {
    scope = "terraform"
    tag   = var.env_name
  }
}

resource "nsxt_logical_router_downlink_port" "services-dp" {
  display_name = "PAS-Services-dp"

  description                   = "Downlink port connecting PAS-Services router to its Logical Switch"
  logical_router_id             = nsxt_logical_tier1_router.t1-services.id
  linked_logical_switch_port_id = nsxt_logical_port.services-lp.id
  ip_address                    = "${cidrhost(var.services_cidr, 1)}/${substr(var.services_cidr, -2, 2)}"

  tag {
    scope = "terraform"
    tag   = var.env_name
  }
}
# }

# Tier-1 Router (Control Plane) {
resource "nsxt_logical_tier1_router" "t1-plane" {
  display_name = "T1-Router-Plane"

  description     = "Control Plane Tier 1 Router."

  enable_router_advertisement = true
  advertise_connected_routes  = true

  tag {
    scope = "terraform"
    tag   = var.env_name
  }
}

resource "nsxt_logical_router_link_port_on_tier1" "t1-plane-to-t0" {
  display_name = "T1-PAS-Infrastructure-to-T0"

  description                   = "Link Port on Infrastructure Tier 1 Router connecting to Logical Tier 0 Router. Provisioned by Terraform."
  logical_router_id             = nsxt_logical_tier1_router.t1-plane.id
  linked_logical_router_port_id = nsxt_logical_router_link_port_on_tier0.t0-to-t1-plane.id

  tag {
    scope = "terraform"
    tag   = var.env_name
  }
}

resource "nsxt_logical_switch" "plane-ls" {
  display_name = "plane"

  transport_zone_id = data.nsxt_transport_zone.overlay-transport-zone.id
  admin_state       = "UP"

  description      = "Logical Switch for the T1 Control Plane."
  replication_mode = "MTEP"

  tag {
    scope = "terraform"
    tag   = var.env_name
  }
}

resource "nsxt_logical_port" "plane-lp" {
  display_name = "plane-lp"

  admin_state       = "UP"
  description       = "Logical Port on the Logical Switch for the T1 Control Plane."
  logical_switch_id = nsxt_logical_switch.plane-ls.id

  tag {
    scope = "terraform"
    tag   = var.env_name
  }
}

resource "nsxt_logical_router_downlink_port" "plane-dp" {
  display_name = "plane-dp"

  description                   = "Downlink port connecting Control Plane router to its Logical Switch"
  logical_router_id             = nsxt_logical_tier1_router.t1-plane.id
  linked_logical_switch_port_id = nsxt_logical_port.plane-lp.id
  ip_address                    = "${cidrhost(var.plane_cidr, 1)}/${substr(var.plane_cidr, -2, 2)}"

  tag {
    scope = "terraform"
    tag   = var.env_name
  }
}
# }


# Extras {
resource "nsxt_ip_pool" "pas-external-ip-pool" {
  description = "PAS Org SNAT Pool"
  display_name = "pas-external-ip-pool"

  subnet {
    allocation_ranges = ["${cidrhost(var.pas_external_ip_pool_cidr, 1)}-${cidrhost(var.pas_external_ip_pool_cidr, -5)}"]
    cidr              = var.pas_external_ip_pool_cidr
  }

  tag {
    scope = "terraform"
    tag   = var.env_name
  }
}

resource "nsxt_ip_pool" "pks-external-ip-pool" {
  description = "PKS Namespace SNAT Pool"
  display_name = "pks-external-ip-pool"

  subnet {
    allocation_ranges = ["${cidrhost(var.pks_external_ip_pool_cidr, 1)}-${cidrhost(var.pks_external_ip_pool_cidr, -2)}"]
    cidr              = var.pks_external_ip_pool_cidr
  }

  tag {
    scope = "terraform"
    tag   = var.env_name
  }
}

resource "nsxt_ip_block" "pas-container-ip-block" {
  description  = "PAS subnets are allocated from this pool to each newly-created Org"
  display_name = "pas-container-block"
  cidr         = var.pas_container_ip_block_cidr
}

resource "nsxt_ip_block" "pks-node-ip-block" {
  description  = "PKS subnets are allocated from this pool to each newly-created K8S cluster"
  display_name = "pks-node-block"
  cidr         = var.pks_node_ip_block_cidr
}

resource "nsxt_ip_block" "pks-pod-ip-block" {
  description  = "PKS subnets are allocated from this pool to each newly-created K8s Namespace"
  display_name = "pks-pod-block"
  cidr         = var.pks_pod_ip_block_cidr
}