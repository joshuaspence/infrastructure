locals {
  gateway_lan_interfaces = sort([for network in unifi_network.network : network.vlan_id > 0 ? "eth0.${network.vlan_id}" : "eth0" if network.purpose != "guest"])

  device_discovery = [
    {
      name = "TP-Link Kasa"
      port = 9999
    },
    {
      name = "Tuya"
      port = 6667
    },
  ]

  bcast_relay_config = {
    id = {
      for index, device_discovery in local.device_discovery : index + 1 => {
        description = "${device_discovery.name} Discovery"
        interface   = local.gateway_lan_interfaces
        port        = device_discovery.port
      }
    }
  }
}

resource "unifi_firewall_group" "device_discovery" {
  name    = "Device Discovery"
  type    = "port-group"
  members = [for device_discovery in local.device_discovery : device_discovery.port]
}

resource "unifi_firewall_rule" "device_discovery" {
  ruleset    = "LAN_OUT"
  rule_index = 2003

  name     = "Allow device discovery"
  action   = "accept"
  protocol = "udp"

  src_firewall_group_ids = [unifi_firewall_group.device_discovery.id]
  dst_network_id         = unifi_network.network["main"].id
}
