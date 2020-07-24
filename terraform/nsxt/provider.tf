provider "nsxt" {
  username = var.nsxt_username
  password = var.nsxt_password
  host     = var.nsxt_host

  allow_unverified_ssl = true
  max_retries           = 10
  retry_min_delay       = 500
  retry_max_delay       = 5000
  retry_on_status_codes = [429]
}