variable "nordvpn_auth" {
  type = object({
    username = string
    password = string
  })
  sensitive = true
}

variable "unifi_access_points" {
  type = map(object({
    mac   = string
    ports = optional(number)

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
      ssid         = string
      passphrase   = string
      security     = optional(string, "wpa2")
      band         = optional(string, "both")
      hide_ssid    = optional(bool)
      fast_roaming = optional(bool)
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

variable "unifi_switch_ports" {
  type = set(object({
    name    = string
    number  = number
    profile = optional(string)
  }))

  default = []
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

  access_points = var.unifi_access_points
  certbot = {
    credentials = {
      aws_access_key_id     = aws_iam_access_key.certbot.id
      aws_secret_access_key = aws_iam_access_key.certbot.secret
    }
    domains = {
      protect = aws_route53_record.unifi_client["protect"].fqdn
      unifi   = aws_route53_record.unifi_client["unifi"].fqdn
    }
    email = format("josh@%s", googleworkspace_domain.secondary["spence.network"].domain_name)
  }
  clients             = var.unifi_clients
  network_ipv6_subnet = var.unifi_network_ipv6_subnet
  networks            = var.unifi_networks
  nordvpn_auth        = var.nordvpn_auth
  ssh_config          = var.unifi_ssh_config
  switch_ports        = var.unifi_switch_ports
  vpn                 = merge(var.unifi_vpn, { gateway = aws_route53_record.vpn.fqdn })
}

output "unifi_nordvpn_config" {
  value = module.unifi.nordvpn_config
}

output "unifi_vpn_network_manager_connections" {
  value     = module.unifi.network_manager_connections
  sensitive = true
}

resource "aws_route53_record" "unifi_client" {
  zone_id  = aws_route53_zone.main["spence.network"].zone_id
  name     = each.key
  type     = "A"
  ttl      = 60 * 5
  records  = [each.value]
  for_each = module.unifi.dns_records
}

# TODO: Use IPv6 address for VPN.
resource "aws_route53_record" "vpn" {
  zone_id = aws_route53_zone.main["spence.network"].zone_id
  name    = "vpn"
  type    = "A"
  ttl     = 60 * 60
  records = [var.unifi_vpn.gateway]
}
