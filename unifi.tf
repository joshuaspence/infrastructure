variable "unifi_access_points" {
  type = map(object({
    mac   = string
    ports = optional(number, 0)
    tags  = optional(set(string))

    uplink = object({
      switch = string
      port   = number
    })
  }))
}

variable "unifi_clients" {
  type = map(object({
    mac  = string
    name = optional(string)
    note = optional(string)

    network    = optional(string)
    fixed_ip   = optional(string)
    dns_record = optional(string)

    device_fingerprint_id = optional(number)

    uplink = optional(object({
      access_point = optional(string)
      switch       = optional(string)
      port         = number
      profile      = optional(string)
    }))
  }))
}

variable "unifi_network_ipv6_subnet" {
  type = string
}

variable "unifi_networks" {
  type = map(object({
    name        = string
    purpose     = optional(string, "corporate")
    subnet      = string
    vlan        = optional(number)
    domain_name = optional(string)

    wifi = optional(object({
      ssid           = string
      passphrase     = string
      security       = optional(string, "wpa2")
      bands          = optional(set(string))
      hide_ssid      = optional(bool)
      fast_roaming   = optional(bool)
      bss_transition = optional(bool)
      enhanced_iot   = optional(bool)
    }))
  }))
}

variable "unifi_ssh_config" {
  type = object({
    username = string
    password = string

    keys = set(object({
      name    = string
      type    = string
      comment = optional(string)
      key     = string
    }))
  })

  default = {
    username = ""
    password = ""
    keys     = []
  }
}

variable "unifi_switches" {
  type = map(object({
    mac   = string
    name  = optional(string)
    ports = optional(number, 0)

    port_overrides = optional(map(object({
      name    = optional(string)
      op_mode = optional(string)
    })), {})

    uplink = optional(object({
      switch = string
      port   = number
    }))
  }))
}

variable "unifi_vpn" {
  type = object({
    gateway = string
    subnet  = string
    secret  = string
    users = map(object({
      password = string
      network  = string
    }))
  })
}

module "unifi" {
  source = "./unifi"

  access_points       = var.unifi_access_points
  clients             = var.unifi_clients
  network_ipv6_subnet = var.unifi_network_ipv6_subnet
  networks            = var.unifi_networks
  ssh_config          = var.unifi_ssh_config
  switches            = var.unifi_switches
  vpn                 = merge(var.unifi_vpn, { gateway = aws_route53_record.vpn.fqdn })
}
