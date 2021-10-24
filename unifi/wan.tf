resource "unifi_network" "wan" {
  name    = "WAN"
  purpose = "wan"

  wan_networkgroup = "WAN"
  wan_type         = "dhcp"
  wan_dns          = ["1.1.1.1", "8.8.8.8"]

  # TODO: Remove this after https://github.com/paultyng/terraform-provider-unifi/issues/107.
  lifecycle {
    ignore_changes = [dhcp_lease, ipv6_interface_type, network_group]
  }
}

resource "unifi_network" "failover_wan" {
  name    = "Failover WAN"
  purpose = "wan"

  wan_networkgroup = "WAN2"
  wan_type         = "dhcp"
  wan_dns          = ["1.1.1.1", "8.8.8.8"]

  # TODO: Remove this after https://github.com/paultyng/terraform-provider-unifi/issues/107.
  lifecycle {
    ignore_changes = [dhcp_lease, ipv6_interface_type, network_group]
  }
}

# TODO: Improve this.
resource "unifi_static_route" "failover_wan" {
  name      = "Failover WAN Admin UI"
  network   = "192.168.200.0/24"
  type      = "interface-route"
  interface = unifi_network.failover_wan.wan_networkgroup

  # TODO: This shouldn't be needed.
  distance = 1

  lifecycle {
    ignore_changes = [distance]
  }
}

# TODO: Use `config.gateway.json` instead, see https://help.ui.com/hc/en-us/articles/215458888-UniFi-USG-Advanced-Configuration-Using-config-gateway-json.
resource "null_resource" "gateway_config" {
  connection {
    host = "Gateway.local"
    user = "josh"
  }

  provisioner "remote-exec" {
    inline = [for command in [
      "begin",
      "set firewall modify LOAD_BALANCE rule 2005 action accept",
      format("set firewall modify LOAD_BALANCE rule 2005 destination address %s", unifi_static_route.failover_wan.network),
      "commit",
      "end",
    ] : format("/opt/vyatta/sbin/vyatta-cfg-cmd-wrapper %s", command)]
  }
}
