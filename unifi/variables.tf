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
      band       = optional(string)
    })
  }))
}

variable "ssh_keys" {
  type = set(object({
    name    = string
    type    = string
    comment = optional(string)
    key     = string
  }))
  default = []
}

variable "switch_port_overrides" {
  type = map(object({
    name    = optional(string)
    profile = optional(string)
  }))
}
