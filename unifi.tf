variable "unifi_access_points" {
  type = map(string)
}

variable "unifi_clients" {
  type = map(object({
    mac  = string
    name = optional(string)
    note = optional(string)

    network  = optional(string)
    fixed_ip = optional(string)

    device_fingerprint_id = optional(number)

    switch_port = optional(object({
      number  = number
      profile = optional(string)
    }))
  }))
}

variable "unifi_networks" {
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

variable "unifi_vpn" {
  type = object({
    gateway = string
    subnet  = string
    secret  = string
    users   = map(string)
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
      protect = aws_route53_record.unifi_protect.fqdn
      unifi   = aws_route53_record.unifi_network.fqdn
    }
    email = format("josh@%s", googleworkspace_domain_alias.main["spence.network"].domain_alias_name)
  }
  clients    = var.unifi_clients
  networks   = var.unifi_networks
  ssh_config = var.unifi_ssh_config
  vpn        = merge(var.unifi_vpn, { gateway = aws_route53_record.vpn.fqdn })
}

output "unifi_vpn_network_manager_connections" {
  value     = module.unifi.network_manager_connections
  sensitive = true
}

resource "aws_route53_record" "home_assistant" {
  zone_id = aws_route53_zone.main["spence.network"].zone_id
  name    = "homeassistant"
  type    = "A"
  ttl     = 60 * 5
  records = [module.unifi.dns_records["home_assistant"]]
}

resource "aws_route53_record" "unifi_network" {
  zone_id = aws_route53_zone.main["spence.network"].zone_id
  name    = "unifi"
  type    = "A"
  ttl     = 60 * 5
  records = [module.unifi.dns_records["unifi_network"]]
}

resource "aws_route53_record" "unifi_protect" {
  zone_id = aws_route53_zone.main["spence.network"].zone_id
  name    = "protect"
  type    = "A"
  ttl     = 60 * 5
  records = [module.unifi.dns_records["unifi_protect"]]
}

# TODO: Use IPv6 address for VPN.
resource "aws_route53_record" "vpn" {
  zone_id = aws_route53_zone.main["spence.network"].zone_id
  name    = "vpn"
  type    = "A"
  ttl     = 60 * 60
  records = [var.unifi_vpn.gateway]
}
