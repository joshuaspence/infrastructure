resource "unifi_firewall_rule" "not_hass" {
  name       = "Allow NoT LAN to Home Assistant"
  action     = "accept"
  protocol   = "all"
  rule_index = 2000
  ruleset    = "LAN_OUT"

  src_network_id    = unifi_network.not.id
  dst_address       = unifi_user.client["home_assistant"].ip
  state_established = true
  state_related     = true
}

resource "unifi_firewall_rule" "not_lan" {
  name           = "Drop outbound NoT LAN traffic"
  action         = "drop"
  protocol       = "all"
  rule_index     = 2001
  ruleset        = "LAN_OUT"
  logging        = true
  src_network_id = unifi_network.not.id
}

resource "unifi_firewall_rule" "not_wan" {
  name           = "Drop outbound NoT WAN traffic"
  action         = "drop"
  protocol       = "all"
  rule_index     = 2000
  ruleset        = "WAN_OUT"
  logging        = true
  src_network_id = unifi_network.not.id
}
