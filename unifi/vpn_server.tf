resource "unifi_setting_radius" "vpn" {
  secret = var.vpn.secret
}

resource "unifi_radius_profile" "default" {
  name                = "Default"
  use_usg_auth_server = true

  lifecycle {
    ignore_changes = [acct_server, auth_server, interim_update_interval]
  }
}

# TODO: Set `vlan_id`.
resource "unifi_account" "vpn" {
  name               = each.key
  password           = each.value.password
  tunnel_type        = 3
  tunnel_medium_type = 1

  for_each = var.vpn.users
}

# TODO: `purpose` should be `remote-user-vpn`.
resource "unifi_network" "vpn" {
  name    = "VPN"
  purpose = "corporate"

  subnet     = var.vpn.subnet
  dhcp_start = cidrhost(var.vpn.subnet, 1)
  dhcp_stop  = cidrhost(var.vpn.subnet, -2)

  lifecycle {
    ignore_changes = [dhcp_lease, dhcp_v6_dns_auto, dhcp_v6_lease, ipv6_interface_type, ipv6_ra_preferred_lifetime, ipv6_ra_valid_lifetime, network_group, purpose]
  }
}

output "network_manager_connections" {
  value = {
    for username, user in var.vpn.users : username => <<-EOT
    [connection]
    id=Home

    [vpn]
    gateway=${var.vpn.gateway}
    ipsec-enabled=true
    service-type=org.freedesktop.NetworkManager.l2tp
    user=${username}
    refuse-eap=true
    refuse-pap=true
    refuse-chap=true
    refuse-mschap=true

    [vpn-secrets]
    ipsec-psk=${var.vpn.secret}
    password=${user.password}

    [ip4]
    method=auto
    dns-search=${join(";", distinct([for network in unifi_network.network : network.domain_name if network.domain_name != ""]))}
    routes=${join(";", [for network in unifi_network.network : network.subnet])}
    never-default=true

    [ipv6]
    method=auto
    never-default=true
    EOT
  }

  sensitive = true
}
