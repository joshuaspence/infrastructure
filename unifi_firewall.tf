resource "unifi_firewall_group" "iot_not" {
  name    = "IoT and NoT networks"
  type    = "address-group"
  members = [unifi_network.iot.subnet, unifi_network.not.subnet]
}

resource "unifi_firewall_rule" "lan_established" {
  name       = "Allow established/related"
  action     = "accept"
  protocol   = "all"
  rule_index = 2000
  ruleset    = "LAN_OUT"

  src_firewall_group_ids = [unifi_firewall_group.iot_not.id]
  state_established      = true
  state_related          = true
}

resource "unifi_firewall_rule" "lan_outbound" {
  name       = "Drop outbound IoT/NoT LAN traffic"
  action     = "drop"
  protocol   = "all"
  rule_index = 2100
  ruleset    = "LAN_OUT"
  logging    = true

  src_firewall_group_ids = [unifi_firewall_group.iot_not.id]
}

resource "unifi_firewall_rule" "not_ntp" {
  name       = "Allow outbound NoT NTP traffic"
  action     = "accept"
  protocol   = "udp"
  rule_index = 2000
  ruleset    = "WAN_OUT"
  logging    = true

  src_network_id = unifi_network.not.id
  dst_port       = 123
}

resource "unifi_firewall_rule" "not_wan" {
  name       = "Drop outbound NoT WAN traffic"
  action     = "drop"
  protocol   = "all"
  rule_index = 2100
  ruleset    = "WAN_OUT"
  logging    = true

  src_network_id = unifi_network.not.id
}
