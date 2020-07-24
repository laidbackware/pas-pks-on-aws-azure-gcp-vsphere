# General {
variable "nsxt_host" {
  description = "The NSX-T host. Must resolve to a reachable IP address, e.g. `nsxmgr.example.tld`"
  type        = string
}

variable "nsxt_username" {
  default     = "admin"
  description = "The NSX-T username, probably `admin`"
  type        = string
}

variable "nsxt_password" {
  description = "The NSX-T password"
  type        = string
}

variable "env_name" {
  description = "An identifier used to tag resources; examples: `dev`, `EMEA`, `prod`"
  type	      = string
}

variable "overlay_transport_zone_name" {
  description = "The name of the Transport Zone that carries internal traffic between the NSX-T components. Also known as the `overlay` transport zone"
  type        = string
}

variable "infrastructure_cidr" {
  description = "The CIDR for the PAS Infrastructure network. Must be reachable from clients outside the foundation. Can be RFC1918 addresses (10.x, 172.16-31.x, 192.168.x), e.g. `10.195.74.0/24`"
  type        = string
}
variable "deployment_cidr" {
  description = "The CIDR for the PKS Deployment network. Must be reachable from clients outside the foundation. Can be RFC1918 addresses (10.x, 172.16-31.x, 192.168.x), e.g. `10.195.74.0/24`"
  type        = string
}
variable "services_cidr" {
  description = "The CIDR for the PKS Services network. Must be reachable from clients outside the foundation. Can be RFC1918 addresses (10.x, 172.16-31.x, 192.168.x), e.g. `10.195.74.0/24`"
  type        = string
}
variable "plane_cidr" {
  description = "The CIDR for the Control Plane network. Must be reachable from clients outside the foundation. Can be RFC1918 addresses (10.x, 172.16-31.x, 192.168.x), e.g. `10.195.74.0/24`"
  type        = string
}

variable "pas_external_ip_pool_cidr" {
  description = "The CIDR for the External IP Pool. Must be reachable from clients outside the foundation. Can be RFC1918 addresses (10.x, 172.16-31.x, 192.168.x), e.g. `10.195.74.0/24`"
  type        = string
}

variable "pks_external_ip_pool_cidr" {
  description = "The CIDR for the External IP Pool. Must be reachable from clients outside the foundation. Can be RFC1918 addresses (10.x, 172.16-31.x, 192.168.x), e.g. `10.195.74.0/24`"
  type        = string
}

variable "pas_container_ip_block_cidr" {
  description = "The CIDR of the pas container IP Block, e.g. `10.12.0.0/14`"
  type        = string
}

variable "pks_pod_ip_block_cidr" {
  description = "The CIDR of the pks node IP Block, e.g. `10.12.0.0/14`"
  type        = string
}

variable "pks_node_ip_block_cidr" {
  description = "The CIDR of the pks pod IP Block, e.g. `10.12.0.0/14`"
  type        = string
}
# }

# Logical Routers + Switches {
variable "nsxt_edge_cluster_name" {
  description = "The name of the deployed Edge Cluster, e.g. `edge-cluster-1`"
  type        = string
}

variable "nsxt_t0_router_name" {
  default     = "t0-router"
  description = "The name of the T0 router"
  type        = string
}
# }

# Load Balancer {
variable "nsxt_pas_web_monitor_name" {
  default     = "pas-web-monitor"
  description = "The name of the Active Health Monitor (healthcheck) for Web (HTTP(S)) traffic"
  type        = string
}

variable "nsxt_pas_tcp_monitor_name" {
  default     = "pas-tcp-monitor"
  description = "The name of the Active Health Monitor (healthcheck) for TCP traffic"
  type        = string
}

variable "nsxt_pas_ssh_monitor_name" {
  default     = "pas-ssh-monitor"
  description = "The name of the Active Health Monitor (healthcheck) for SSH traffic"
  type        = string
}

variable "nsxt_pas_web_server_pool_name" {
  default     = "pas-web-pool"
  description = "The name of the Server Pool (collection of VMs which handle traffic) for Web (HTTP(S)) traffic"
  type        = string
}

variable "nsxt_pas_tcp_server_pool_name" {
  default     = "pas-tcp-pool"
  description = "The name of the Server Pool (collection of VMs which handle traffic) for TCP traffic"
  type        = string
}

variable "nsxt_pas_ssh_server_pool_name" {
  default     = "pas-ssh-pool"
  description = "The name of the Server Pool (collection of VMs which handle traffic) for SSH traffic"
  type        = string
}

variable "nsxt_pas_web_virtual_server_name" {
  default     = "pas-web-vs"
  description = "The name of the Virtual Server for Web (HTTP(S)) traffic"
  type        = string
}

variable "nsxt_pas_web_virtual_server_ports" {
  default     = ["80", "443"]
  description = "The list of port(s) on which the Virtual Server listens for Web (HTTP(S)) traffic, e.g. `10.195.74.19`"
  type        = list
}

variable "nsxt_pas_tcp_virtual_server_name" {
  default     = "pas-tcp-vs"
  description = "The name of the Virtual Server for TCP traffic"
  type        = string
}

variable "nsxt_pas_tcp_virtual_server_ports" {
  description = "The list of port(s) on which the Virtual Server listens for TCP traffic, e.g. `[\"8080\", \"52135\", \"34000-35000\"]`"
  type        = list
}

variable "nsxt_pas_ssh_virtual_server_name" {
  default     = "pas-ssh-vs"
  description = "The name of the Virtual Server for SSH traffic"
  type        = string
}

variable "nsxt_pas_ssh_virtual_server_ports" {
  default     = ["2222"]
  description = "The list of port(s) on which the Virtual Server listens for SSH traffic"
  type        = list
}

variable "nsxt_pas_name" {
  default     = "pas-lb"
  description = "The name of the Load Balancer itself"
  type        = string
}

variable "nsxt_pas_size" {
  default     = "SMALL"
  description = "The size of the Load Balancer. Accepted values: SMALL, MEDIUM, or LARGE"
  type        = string
}
# }