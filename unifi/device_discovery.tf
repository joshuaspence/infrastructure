locals {
  gateway_lan_interfaces = sort([for network in unifi_network.network : network.vlan_id > 0 ? "eth0.${network.vlan_id}" : "eth0" if network.purpose != "guest"])

  device_discovery = [
    {
      name           = "TP-Link Kasa"
      broadcast_port = 9999
      source_port    = 9999
    },
    {
      name             = "Tuya"
      broadcast_port   = 6667
      destination_port = 6667
    },
    {
      name             = "Daikin Airbase"
      broadcast_port   = 30050
      destination_port = 30000
    }
  ]

  bcast_relay_config = {
    id = {
      for index, device_discovery in local.device_discovery : index + 1 => {
        description = "${device_discovery.name} Discovery"
        interface   = local.gateway_lan_interfaces
        port        = device_discovery.broadcast_port
      }
    }
  }
}

resource "unifi_firewall_group" "device_discovery_source" {
  name    = "Device Discovery (Source)"
  type    = "port-group"
  members = [for device_discovery in local.device_discovery : device_discovery.source_port if can(device_discovery.source_port)]
}

resource "unifi_firewall_group" "device_discovery_destination" {
  name    = "Device Discovery (Destination)"
  type    = "port-group"
  members = [for device_discovery in local.device_discovery : device_discovery.destination_port if can(device_discovery.destination_port)]
}

resource "unifi_firewall_rule" "device_discovery_source" {
  ruleset    = "LAN_OUT"
  rule_index = 2003

  name     = "Allow device discovery (source)"
  action   = "accept"
  protocol = "udp"

  src_firewall_group_ids = [unifi_firewall_group.device_discovery_source.id]
  dst_network_id         = unifi_network.network["main"].id
}

resource "unifi_firewall_rule" "device_discovery_destination" {
  ruleset    = "LAN_OUT"
  rule_index = 2004

  name     = "Allow device discovery (destination)"
  action   = "accept"
  protocol = "udp"

  dst_firewall_group_ids = [unifi_firewall_group.device_discovery_destination.id]
  dst_network_id         = unifi_network.network["main"].id
}
