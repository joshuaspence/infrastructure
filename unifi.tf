variable "unifi_clients" {
  type = map(object({
    mac  = string
    name = optional(string)
    note = optional(string)

    network  = optional(string)
    fixed_ip = optional(string)
  }))
}

variable "home_networks" {
  type = map(object({
    subnet = string
    vlan   = number
  }))
}

variable "home_wlans" {
  type = map(object({
    ssid       = string
    passphrase = string
  }))
}

module "unifi" {
  source = "./unifi"

  clients  = var.unifi_clients
  networks = var.home_networks
  wlans    = var.home_wlans
}
