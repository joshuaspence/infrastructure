resource "unifi_firewall_rule" "not_wan" {
  name           = "Drop outbound NoT traffic"
  action         = "drop"
  protocol       = "all"
  rule_index     = 2000
  ruleset        = "WAN_OUT"
  logging        = true
  src_network_id = unifi_network.not.id
}
