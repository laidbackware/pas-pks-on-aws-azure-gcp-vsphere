# Routers
env_name = "vsphere"

nsxt_t0_router_uplink_ip = "192.168.0.195/24"
nsxt_t0_static_route_next_hop = "192.168.0.1"

infrastructure_cidr     = "10.1.0.0/26"
deployment_cidr         = "10.1.0.64/26"
services_cidr           = "10.1.0.128/26"
plane_cidr           = "10.1.0.192/26"

# Each PAS Org will draw an IP address from this pool; make sure you have enough
# Your LB Virtual Servers, gateway, NAT gateway, OM should be in the CIDR but not in the available range

pks_external_ip_pool_cidr   = "10.1.1.0/25"
# The PAS LB VIPs will be the last 3 addresses in the pas pool block
pas_external_ip_pool_cidr   = "10.1.1.128/25"

pas_container_ip_block_cidr = "10.1.192.0/18"
pks_node_ip_block_cidr      = "10.1.64.0/18"
pks_pod_ip_block_cidr       = "10.1.128.0/18"

nsxt_pas_web_virtual_server_ports = ["80", "443"]
nsxt_pas_tcp_virtual_server_ports = ["8080", "52135", "34000-35000"]
nsxt_pas_ssh_virtual_server_ports = ["2222"]
