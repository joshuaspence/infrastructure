locals {
  device_discovery = [
    {
      name           = "DHCP"
      broadcast_port = 67
    },
    {
      name             = "Daikin Airbase"
      broadcast_port   = 30050
      destination_port = 30000
    },
    {
      name           = "TP-Link Kasa"
      broadcast_port = 9999
      source_port    = 9999
    },
    {
      name           = "Tuya"
      broadcast_port = 6667
    },
  ]
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
  rule_index = 20001

  name     = "Allow device discovery (source)"
  action   = "accept"
  protocol = "udp"

  src_firewall_group_ids = [unifi_firewall_group.device_discovery_source.id]
  dst_network_id         = unifi_network.network["trusted"].id
}

resource "unifi_firewall_rule" "device_discovery_destination" {
  ruleset    = "LAN_OUT"
  rule_index = 20002

  name     = "Allow device discovery (destination)"
  action   = "accept"
  protocol = "udp"

  dst_firewall_group_ids = [unifi_firewall_group.device_discovery_destination.id]
  dst_network_id         = unifi_network.network["trusted"].id
}
