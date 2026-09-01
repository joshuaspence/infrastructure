resource "unifi_wan" "primary" {
  name               = "NBN"
  networkgroup       = "WAN"
  type               = "dhcp"
  type_v6            = "dhcpv6"
  setting_preference = "manual"
  
  dns = {
    preference      = "manual"
    primary         = "1.1.1.1"
    secondary       = "8.8.8.8"
    ipv6_preference = "manual"
    ipv6_primary    = "2606:4700:4700::1111"
    ipv6_secondary  = "2001:4860:4860::8888"
  }

  load_balance = {
    type   = "weighted"
    weight = 50
  }

  provider_capabilities = {
    download_kilobits_per_second = 500 * 1000
    upload_kilobits_per_second   = 50 * 1000
  }
}

resource "unifi_wan" "secondary" {
  name               = "Secondary"
  networkgroup       = "WAN2"
  setting_preference = "auto"
}

resource "unifi_wan" "tertiary" {
  name               = "UniFi U5G Max"
  networkgroup       = "WAN3"
  setting_preference = "auto"
}
