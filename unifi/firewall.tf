resource "unifi_firewall_group" "iot_not" {
  name    = "IoT and NoT networks"
  type    = "address-group"
  members = [unifi_network.network["iot"].subnet, unifi_network.network["not"].subnet]
}

resource "unifi_firewall_rule" "lan_established" {
  ruleset    = "LAN_IN"
  rule_index = 2000
  name       = "Allow established/related connections to LAN network"
  action     = "accept"
  protocol   = "all"

  state_established = true
  state_related     = true

  src_firewall_group_ids = [unifi_firewall_group.iot_not.id]
  dst_network_id         = unifi_network.network["main"].id
}

resource "unifi_firewall_rule" "lan_outbound" {
  name       = "Drop outbound IoT/NoT LAN traffic"
  action     = "drop"
  protocol   = "all"
  rule_index = 2100
  ruleset    = "LAN_IN"
  logging    = true

  src_firewall_group_ids = [unifi_firewall_group.iot_not.id]
}

resource "unifi_firewall_rule" "not_ntp" {
  name       = "Allow outbound NoT NTP traffic"
  action     = "accept"
  protocol   = "udp"
  rule_index = 2000
  ruleset    = "WAN_OUT"

  src_network_id = unifi_network.network["not"].id
  dst_port       = 123
}

resource "unifi_firewall_group" "not_wan_silent" {
  name    = "NoT WAN Silent Ports"
  type    = "port-group"
  members = [80, 443, 50443, 60443]
}

resource "unifi_firewall_rule" "not_wan_silent" {
  name       = "Drop outbound NoT WAN traffic"
  action     = "drop"
  protocol   = "all"
  rule_index = 2100
  ruleset    = "WAN_OUT"

  src_network_id         = unifi_network.network["not"].id
  dst_firewall_group_ids = [unifi_firewall_group.not_wan_silent.id]
}

resource "unifi_firewall_rule" "not_wan_logged" {
  name       = "Drop outbound NoT WAN traffic"
  action     = "drop"
  protocol   = "all"
  rule_index = 2101
  ruleset    = "WAN_OUT"
  logging    = true

  src_network_id = unifi_network.network["not"].id
}
