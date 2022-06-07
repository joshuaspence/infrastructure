# TODO: Manage RADIUS server.
# TODO: Manage RADIUS users.
# TODO: This doesn't seem to be working on the UXG.

data "unifi_radius_profile" "default" {}

# TODO: `purpose` should be `remote-user-vpn`.
resource "unifi_network" "vpn" {
  name    = "VPN"
  purpose = "corporate"

  subnet     = var.vpn.subnet
  dhcp_start = cidrhost(var.vpn.subnet, 1)
  dhcp_stop  = cidrhost(var.vpn.subnet, -2)

  lifecycle {
    ignore_changes = [dhcp_lease, ipv6_interface_type, network_group, purpose]
  }
}

output "network_manager_connections" {
  value = {
    for user, password in var.vpn.users : user => <<-EOT
    [connection]
    id=Home

    [vpn]
    gateway=${var.vpn.gateway}
    ipsec-enabled=true
    service-type=org.freedesktop.NetworkManager.l2tp
    user=${user}
    refuse-eap=true
    refuse-pap=true
    refuse-chap=true
    refuse-mschap=true

    [vpn-secrets]
    ipsec-psk=${var.vpn.secret}
    password=${password}

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
