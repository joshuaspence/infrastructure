variable "unifi_access_points" {
  type = map(string)
}

variable "unifi_clients" {
  type = map(object({
    mac  = string
    name = optional(string)
    note = optional(string)

    network  = optional(string)
    fixed_ip = optional(string)

    device_fingerprint_id = optional(number)
  }))
}

variable "unifi_networks" {
  type = map(object({
    name         = string
    purpose      = optional(string)
    subnet       = string
    vlan         = optional(number)
    domain_name  = optional(string)
    ipv6_enabled = optional(bool)

    wifi = object({
      ssid       = string
      passphrase = string
      band       = optional(string)
      hide_ssid  = optional(bool)
    })
  }))
}

variable "unifi_ssh_keys" {
  type = set(object({
    name    = string
    type    = string
    comment = optional(string)
    key     = string
  }))
  default = []
}

variable "unifi_switch_port_overrides" {
  type = map(object({
    name    = optional(string)
    profile = optional(string)
  }))
}

module "unifi" {
  source = "./unifi"

  access_points         = var.unifi_access_points
  clients               = var.unifi_clients
  networks              = var.unifi_networks
  ssh_keys              = var.unifi_ssh_keys
  switch_port_overrides = var.unifi_switch_port_overrides
}

output "unifi_gateway_config" {
  value = module.unifi.gateway_config
}
