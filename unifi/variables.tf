variable "clients" {
  type = map(object({
    mac  = string
    name = optional(string)
    note = optional(string)

    network  = optional(string)
    fixed_ip = optional(string)
  }))
}

variable "networks" {
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

variable "wlans" {
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
