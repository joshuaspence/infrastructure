data "unifi_ap_group" "default" {}

resource "unifi_site" "default" {
  description = "Home"
}

/*
resource "unifi_setting_mgmt" "default" {
  auto_upgrade = true
}
*/

resource "unifi_user_group" "default" {
  name = "Default"
}
