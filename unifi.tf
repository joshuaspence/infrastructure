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
  type = object({
    main = object({
      subnet = string
      vlan   = number
    })

    iot = object({
      subnet = string
      vlan   = number
    })

    not = object({
      subnet = string
      vlan   = number
    })
  })
}

variable "home_wifi" {
  type = object({
    main = object({
      ssid       = string
      passphrase = string
    })

    iot = object({
      ssid       = string
      passphrase = string
    })

    not = object({
      ssid       = string
      passphrase = string
    })
  })
}

module "unifi" {
  source = "./unifi"

  home_networks = var.home_networks
  home_wifi     = var.home_wifi
  unifi_clients = var.unifi_clients
}
