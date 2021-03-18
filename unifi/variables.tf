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
  type = map(object({
    name   = string
    subnet = string
    vlan   = optional(number)

    wifi = object({
      ssid       = string
      passphrase = string
    })
  }))
}
