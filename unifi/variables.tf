variable "access_points" {
  type = map(object({
    mac   = string
    ports = optional(number, 0)
    tags  = optional(set(string), [])

    uplink = object({
      switch = string
      port   = number
    })
  }))
}

variable "clients" {
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
      network      = optional(string)
    }))
  }))

  # `network` and `fixed_ip` are paired. A reservation needs to say which network it belongs to, and `network` on its
  # own only overrides the VLAN, which the port does.
  validation {
    condition     = length([for key, client in var.clients : key if(client.network != null) != (client.fixed_ip != null)]) == 0
    error_message = format("Clients must set both `network` and `fixed_ip` or neither: %s.", join(", ", [for key, client in var.clients : key if(client.network != null) != (client.fixed_ip != null)]))
  }

  # An uplink must configure a switch OR access point port.
  validation {
    condition     = length([for key, client in var.clients : key if client.uplink != null && (client.uplink.switch != null) == (client.uplink.access_point != null)]) == 0
    error_message = format("An uplink must name either a switch or an access point, not both and not neither: %s.", join(", ", [for key, client in var.clients : key if client.uplink != null && (client.uplink.switch != null) == (client.uplink.access_point != null)]))
  }

  validation {
    condition     = length([for key, client in var.clients : key if client.uplink != null && client.uplink.port > (client.uplink.switch != null ? try(var.switches[client.uplink.switch].ports, 0) : try(var.access_points[client.uplink.access_point].ports, 0))]) == 0
    error_message = format("An uplink must name a port that exists on the device it names: %s.", join(", ", [for key, client in var.clients : key if client.uplink != null && client.uplink.port > (client.uplink.switch != null ? try(var.switches[client.uplink.switch].ports, 0) : try(var.access_points[client.uplink.access_point].ports, 0))]))
  }

  validation {
    condition     = length([for key, client in var.clients : key if try(client.uplink.network, null) != null && !contains(keys(var.networks), client.uplink.network)]) == 0
    error_message = format("An uplink must name a network that exists: %s.", join(", ", [for key, client in var.clients : key if try(client.uplink.network, null) != null && !contains(keys(var.networks), client.uplink.network)]))
  }

  # Two clients on one port would collide when the ports are built, and the resulting duplicate key error does not say
  # which clients are involved.
  validation {
    condition     = length([for port, keys in { for key, client in var.clients : format("%s/%d", coalesce(client.uplink.switch, client.uplink.access_point, "?"), client.uplink.port) => key... if client.uplink != null } : port if length(keys) > 1]) == 0
    error_message = format("Each device port takes one client: %s.", join("; ", [for port, keys in { for key, client in var.clients : format("%s/%d", coalesce(client.uplink.switch, client.uplink.access_point, "?"), client.uplink.port) => key... if client.uplink != null } : format("%s has %s", port, join(" and ", keys)) if length(keys) > 1]))
  }
}

variable "dns_records" {
  type     = map(string)
  default  = {}
  nullable = false
}

variable "network_ipv6_subnet" {
  type = string
}

variable "networks" {
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
      bss_transition = optional(bool, true)
      enhanced_iot   = optional(bool, false)
    }))
  }))

  validation {
    condition     = alltrue([for network in var.networks : contains(["wpa2", "wpa3"], network.wifi.security) if network.wifi != null])
    error_message = "Security must be one of: wpa2, wpa3"
  }
}

variable "ssh_config" {
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

variable "switches" {
  type = map(object({
    mac   = string
    name  = optional(string)
    ports = optional(number, 0)

    port_overrides = optional(map(object({
      name    = optional(string)
      op_mode = optional(string)
    })), {})
  }))
}

variable "vpn" {
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
