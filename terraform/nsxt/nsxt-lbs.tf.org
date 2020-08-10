# Active Health Monitors {
resource "nsxt_lb_http_monitor" "pas-web-monitor" {
  description           = "The Active Health Monitor (healthcheck) for Web (HTTP(S)) traffic."
  display_name          = var.nsxt_pas_web_monitor_name
  monitor_port          = 8080
  request_method        = "GET"
  request_url           = "/health"
  request_version       = "HTTP_VERSION_1_1"
  response_status_codes = [200]

  tag {
    scope = "terraform"
    tag   = var.env_name
  }
}

resource "nsxt_lb_http_monitor" "pas-tcp-monitor" {
  description           = "The Active Health Monitor (healthcheck) for TCP traffic."
  display_name          = "var.nsxt_pas_tcp_monitor_name"
  monitor_port          = 80
  request_method        = "GET"
  request_url           = "/health"
  request_version       = "HTTP_VERSION_1_1"

  tag {
    scope = "terraform"
    tag   = var.env_name
  }
  response_status_codes = [200]
}

resource "nsxt_lb_tcp_monitor" "pas-ssh-monitor" {
  description           = "The Active Health Monitor (healthcheck) for SSH traffic."
  display_name          = var.nsxt_pas_ssh_monitor_name
  monitor_port          = 2222

  tag {
    scope = "terraform"
    tag   = var.env_name
  }
}
# }

# Server Pools {
resource "nsxt_lb_pool" "pas-web-pool" {
  description              = "The Server Pool of Web (HTTP(S)) traffic handling VMs"
  display_name             = var.nsxt_pas_web_server_pool_name
  algorithm                = "ROUND_ROBIN"
  tcp_multiplexing_enabled = false
  active_monitor_id        = nsxt_lb_http_monitor.pas-web-monitor.id

	snat_translation {
		type          = "SNAT_AUTO_MAP"
	}

  tag {
    scope = "terraform"
    tag   = var.env_name
  }
}

resource "nsxt_lb_pool" "pas-tcp-pool" {
  description              = "The Server Pool of TCP traffic handling VMs"
  display_name             = var.nsxt_pas_tcp_server_pool_name
  algorithm                = "ROUND_ROBIN"
  tcp_multiplexing_enabled = false
  active_monitor_id        = nsxt_lb_http_monitor.pas-tcp-monitor.id

	snat_translation {
		type          = "TRANSPARENT"
	}

  tag {
    scope = "terraform"
    tag   = var.env_name
  }
}

resource "nsxt_lb_pool" "pas-ssh-pool" {
  description              = "The Server Pool of SSH traffic handling VMs"
  display_name             = var.nsxt_pas_ssh_server_pool_name
  algorithm                = "ROUND_ROBIN"
  tcp_multiplexing_enabled = false
  active_monitor_id        = nsxt_lb_tcp_monitor.pas-ssh-monitor.id

	snat_translation {
		type          = "TRANSPARENT"
	}

  tag {
    scope = "terraform"
    tag   = var.env_name
  }
}
# }

# Virtual Servers {
resource "nsxt_lb_fast_tcp_application_profile" "pas-lb-tcp-application-profile" {
  display_name      = "pas-lb-tcp-application-profile"
  close_timeout     = "8"
  idle_timeout      = "1800"

  tag {
    scope = "terraform"
    tag   = var.env_name
  }
}

resource "nsxt_lb_tcp_virtual_server" "pas-web-virtual-server" {
  description                = "The Virtual Server for Web (HTTP(S)) traffic"
  display_name               = var.nsxt_pas_web_virtual_server_name
  application_profile_id     = nsxt_lb_fast_tcp_application_profile.pas-lb-tcp-application-profile.id
  ip_address                 = cidrhost(var.pas_external_ip_pool_cidr, -4)
  ports                      = var.nsxt_pas_web_virtual_server_ports
  pool_id                    = nsxt_lb_pool.pas-web-pool.id

  tag {
    scope = "terraform"
    tag   = var.env_name
  }
}

resource "nsxt_lb_tcp_virtual_server" "pas-tcp-virtual-server" {
  description                = "The Virtual Server for TCP traffic"
  display_name               = var.nsxt_pas_tcp_virtual_server_name
  application_profile_id     = nsxt_lb_fast_tcp_application_profile.pas-lb-tcp-application-profile.id
  ip_address                 = cidrhost(var.pas_external_ip_pool_cidr, -3)
  ports                      = var.nsxt_pas_tcp_virtual_server_ports
  pool_id                    = nsxt_lb_pool.pas-tcp-pool.id

  tag {
    scope = "terraform"
    tag   = var.env_name
  }
}

resource "nsxt_lb_tcp_virtual_server" "pas-ssh-virtual-server" {
  description                = "The Virtual Server for SSH traffic"
  display_name               = var.nsxt_pas_ssh_virtual_server_name
  application_profile_id     = nsxt_lb_fast_tcp_application_profile.pas-lb-tcp-application-profile.id
  ip_address                 = cidrhost(var.pas_external_ip_pool_cidr, -2)
  ports                      = var.nsxt_pas_ssh_virtual_server_ports
  pool_id                    = nsxt_lb_pool.pas-ssh-pool.id

  tag {
    scope = "terraform"
    tag   = var.env_name
  }
}
# }

# (the) Load Balancer (itself) {
resource "nsxt_lb_service" "pas-lb" {
  description  = "The Load Balancer for handling Web (HTTP(S)), TCP, and SSH traffic."
  display_name = var.nsxt_pas_name

  enabled            = true
  logical_router_id  = nsxt_logical_tier1_router.t1-pas-deployment.id
  size               = var.nsxt_pas_size
  virtual_server_ids = [
    "${nsxt_lb_tcp_virtual_server.pas-web-virtual-server.id}",
    "${nsxt_lb_tcp_virtual_server.pas-tcp-virtual-server.id}",
    "${nsxt_lb_tcp_virtual_server.pas-ssh-virtual-server.id}"
    ]

  tag {
    scope = "terraform"
    tag   = var.env_name
  }
}