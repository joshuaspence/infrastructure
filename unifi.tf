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
  }))
}

variable "unifi_networks" {
  type = map(object({
    name   = string
    subnet = string
    vlan   = optional(number)

    wifi = object({
      ssid       = string
      passphrase = string
      band       = optional(string)
    })
  }))
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
  switch_port_overrides = var.unifi_switch_port_overrides
}
