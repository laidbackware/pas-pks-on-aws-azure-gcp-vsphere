# resource "nsxt_policy_lb_service" "pas_lb" {
#   display_name      = var.nsxt_pas_name
#   description       = "Terraform provisioned Service"
#   connectivity_path = nsxt_policy_tier1_gateway.tier1_gw_platform.path
#   size = var.nsxt_pas_size
#   enabled = true
# }

# data "nsxt_policy_lb_app_profile" "default_tcp_app_profile" {
#   type         = "TCP"
#   display_name = "default-tcp-lb-app-profile"
# }

# # Active Health Monitors {
# resource "nsxt_lb_http_monitor" "pas_web_monitor" {
#   description           = "The Active Health Monitor (healthcheck) for Web (HTTP(S)) traffic."
#   display_name          = var.nsxt_pas_web_monitor_name
#   monitor_port          = 8080
#   request_method        = "GET"
#   request_url           = "/health"
#   request_version       = "HTTP_VERSION_1_1"
#   response_status_codes = [200]
# }

# data "nsxt_policy_lb_monitor" "pas_web_monitor" {
#   type         = "ANY"
#   display_name = var.nsxt_pas_web_monitor_name
# }

# resource "nsxt_policy_lb_pool" "pas_web_pool" {
#     display_name         = var.nsxt_pas_web_server_pool_name
#     description          = "Terraform provisioned LB Pool"
#     algorithm            = "ROUND_ROBIN"
#     tcp_multiplexing_enabled = false
#     active_monitor_path  = data.nsxt_policy_lb_monitor.pas_web_monitor.path
#     snat {
#        type = "AUTOMAP"
#     }
# }

# resource "nsxt_policy_lb_virtual_server" "pas_web_virtual_server" {
#   display_name               = var.nsxt_pas_web_virtual_server_name
#   description                = "Terraform provisioned Virtual Server"
#   application_profile_path   = data.nsxt_policy_lb_app_profile.default_tcp_app_profile.path
#   ip_address                 = cidrhost(var.pas_external_ip_pool_cidr, -4)
#   ports                      = var.nsxt_pas_web_virtual_server_ports
#   default_pool_member_ports  = ["80"]
#   service_path               = nsxt_policy_lb_service.pas_lb.path
#   pool_path                  = nsxt_policy_lb_pool.pas_web_pool.path
# }


# resource "nsxt_lb_http_monitor" "pas-tcp-monitor" {
#   description           = "The Active Health Monitor (healthcheck) for TCP traffic."
#   display_name          = "var.nsxt_pas_tcp_monitor_name"
#   monitor_port          = 80
#   request_method        = "GET"
#   request_url           = "/health"
#   request_version       = "HTTP_VERSION_1_1"

#   response_status_codes = [200]
# }

# resource "nsxt_lb_tcp_monitor" "pas-ssh-monitor" {
#   description           = "The Active Health Monitor (healthcheck) for SSH traffic."
#   display_name          = var.nsxt_pas_ssh_monitor_name
#   monitor_port          = 2222
# }
# # }