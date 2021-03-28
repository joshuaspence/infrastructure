resource "unifi_firewall_group" "xot" {
  name = "XoT Networks"
  type = "address-group"

  members = [
    unifi_network.network["iot"].subnet,
    unifi_network.network["not"].subnet,
  ]
}

resource "unifi_firewall_rule" "established" {
  ruleset    = "LAN_OUT"
  rule_index = 2000

  name     = "Accept established/related connections from XoT networks to main network"
  action   = "accept"
  protocol = "all"

  state_established      = true
  state_related          = true
  src_firewall_group_ids = [unifi_firewall_group.xot.id]
  dst_network_id         = unifi_network.network["main"].id
}

resource "unifi_firewall_rule" "lan_outbound" {
  ruleset    = "LAN_OUT"
  rule_index = 2100

  name     = "Drop inter-VLAN traffic from XoT networks"
  action   = "drop"
  protocol = "all"

  logging                = true
  src_firewall_group_ids = [unifi_firewall_group.xot.id]
}

resource "unifi_firewall_rule" "not_ntp" {
  ruleset    = "WAN_OUT"
  rule_index = 2000

  name     = "Allow outbound NoT NTP traffic"
  action   = "accept"
  protocol = "udp"

  src_network_id = unifi_network.network["not"].id
  dst_port       = 123
}

resource "unifi_firewall_group" "not_wan_silent" {
  name    = "NoT WAN Silent Ports"
  type    = "port-group"
  members = [80, 443, 50443, 60443]
}

resource "unifi_firewall_rule" "not_wan_silent" {
  ruleset    = "WAN_OUT"
  rule_index = 2100

  name     = "Drop outbound NoT WAN traffic"
  action   = "drop"
  protocol = "all"

  src_network_id         = unifi_network.network["not"].id
  dst_firewall_group_ids = [unifi_firewall_group.not_wan_silent.id]
}

resource "unifi_firewall_rule" "not_wan_logged" {
  ruleset    = "WAN_OUT"
  rule_index = 2101

  name     = "Drop outbound NoT WAN traffic"
  action   = "drop"
  protocol = "all"

  logging        = true
  src_network_id = unifi_network.network["not"].id
}
