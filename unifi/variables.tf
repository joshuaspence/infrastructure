variable "access_points" {
  type = map(object({
    mac   = string
    ports = optional(number, 0)

    uplink = object({
      switch = string
      port   = number
    })
  }))
}

variable "certbot" {
  type = object({
    email = string

    credentials = object({
      aws_access_key_id     = string
      aws_secret_access_key = string
    })

    domains = object({
      drive   = string
      network = string
      protect = string
    })
  })
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
      profile      = optional(string)
    }))
  }))

  # `network` and `fixed_ip` are paired.
  validation {
    condition     = length([for client in var.clients : client.mac if(client.network != null) != (client.fixed_ip != null)]) == 0
    error_message = "Parameters network and fixed_ip must either both be set or both be unset."
  }
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
      ssid         = string
      passphrase   = string
      security     = optional(string, "wpa2")
      band         = optional(string)
      hide_ssid    = optional(bool)
      fast_roaming = optional(bool)
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
      name                = optional(string)
      op_mode             = optional(string)
      aggregate_num_ports = optional(number)
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
