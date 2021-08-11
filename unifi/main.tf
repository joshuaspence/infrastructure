data "unifi_ap_group" "default" {}

resource "unifi_site" "default" {
  description = "Home"
}

resource "unifi_setting_mgmt" "default" {
  auto_upgrade = false
  ssh_enabled  = true

  dynamic "ssh_key" {
    for_each = var.ssh_keys

    content {
      name    = ssh_key.value.name
      type    = ssh_key.value.type
      comment = ssh_key.value.comment
      key     = ssh_key.value.key
    }
  }
}

resource "unifi_user_group" "default" {
  name = "Default"
}
