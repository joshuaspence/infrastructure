resource "unifi_firewall_group" "xot" {
  name = "XoT Networks"
  type = "address-group"

  members = [
    cidrsubnet(unifi_network.network["iot"].subnet, 0, 0),
    cidrsubnet(unifi_network.network["not"].subnet, 0, 0),
  ]
}

resource "unifi_firewall_rule" "established" {
  ruleset    = "LAN_OUT"
  rule_index = 20000

  name     = "Accept established/related connections from XoT networks to main network"
  action   = "accept"
  protocol = "all"

  state = {
    established = true
    related     = true
  }

  source = {
    firewall_group_ids = [unifi_firewall_group.xot.id]
  }

  destination = {
    network_id = unifi_network.network["trusted"].id
  }
}

resource "unifi_firewall_rule" "xot_hass" {
  ruleset    = "LAN_OUT"
  rule_index = 20003

  name     = "Allow XoT networks to Home Assistant"
  action   = "accept"
  protocol = "tcp"

  source = {
    firewall_group_ids = [unifi_firewall_group.xot.id]
  }

  destination = {
    address = unifi_client.client["home_assistant"].fixed_ip
  }

  logging = true
}

resource "unifi_firewall_rule" "inter_vlan" {
  ruleset    = "LAN_OUT"
  rule_index = 20004

  name     = "Drop inter-VLAN traffic from XoT networks"
  action   = "drop"
  protocol = "all"

  logging = false

  source = {
    firewall_group_ids = [unifi_firewall_group.xot.id]
  }
}

resource "unifi_firewall_rule" "ntp" {
  ruleset    = "WAN_OUT"
  rule_index = 20000

  name     = "Allow outbound NTP traffic"
  action   = "accept"
  protocol = "udp"

  destination = {
    port = 123
  }
}

resource "unifi_firewall_rule" "not_wan" {
  ruleset    = "WAN_OUT"
  rule_index = 20001

  name     = "Drop outbound NoT WAN traffic"
  action   = "drop"
  protocol = "all"

  source = {
    network_id = unifi_network.network["not"].id
  }
}
