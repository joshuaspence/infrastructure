variable "access_points" {
  type = map(string)
}

variable "clients" {
  type = map(object({
    mac  = string
    name = optional(string)
    note = optional(string)

    network  = optional(string)
    fixed_ip = optional(string)

    device_fingerprint_id = optional(number)
  }))

  # `network` and `fixed_ip` are paired.
  validation {
    condition     = length([for client in var.clients : client.mac if(client.network != null) != (client.fixed_ip != null)]) == 0
    error_message = "Parameters network and fixed_ip must either both be set or both be unset."
  }
}

variable "networks" {
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

variable "switch_port_overrides" {
  type = map(object({
    name    = optional(string)
    profile = optional(string)
  }))
}

variable "vpn" {
  type = object({
    gateway = string
    subnet  = string
    secret  = string
    users   = map(string)
  })
}
