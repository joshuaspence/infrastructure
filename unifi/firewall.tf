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
  rule_index = 20000

  name     = "Accept established/related connections from XoT networks to main network"
  action   = "accept"
  protocol = "all"

  state_established      = true
  state_related          = true
  src_firewall_group_ids = [unifi_firewall_group.xot.id]
  dst_network_id         = unifi_network.network["trusted"].id
}

resource "unifi_firewall_rule" "iot_hass" {
  ruleset    = "LAN_OUT"
  rule_index = 20003

  name     = "Allow IoT network to Home Assistant"
  action   = "accept"
  protocol = "tcp"

  src_network_id = unifi_network.network["iot"].id
  dst_address    = unifi_user.client["home_assistant"].fixed_ip
}

resource "unifi_firewall_rule" "inter_vlan" {
  ruleset    = "LAN_OUT"
  rule_index = 20004

  name     = "Drop inter-VLAN traffic from XoT networks"
  action   = "drop"
  protocol = "all"

  logging                = false
  src_firewall_group_ids = [unifi_firewall_group.xot.id]
}

resource "unifi_firewall_rule" "ntp" {
  ruleset    = "WAN_OUT"
  rule_index = 20000

  name     = "Allow outbound NTP traffic"
  action   = "accept"
  protocol = "udp"

  dst_port = 123
}

resource "unifi_firewall_rule" "not_wan" {
  ruleset    = "WAN_OUT"
  rule_index = 20001

  name     = "Drop outbound NoT WAN traffic"
  action   = "drop"
  protocol = "all"

  src_network_id = unifi_network.network["not"].id
}
