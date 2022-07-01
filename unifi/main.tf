/**
 * TODO: Manage the following resources:
 *
 * - Users (/users/users)
 * - UniFi OS network (/settings/general)
 * - UniFi OS notifications (/settings/notifications)
 * - UniFi OS updates (/settings/updates)
 * - UniFi OS location (/settings/location)
 * - UniFi OS advanced (/settings/advanced)
 * - Settings > Site > LED and Screen Settings
 * - Settings > Site > Services
 */

data "unifi_ap_group" "default" {}

resource "unifi_site" "default" {
  description = "Home"
}

// TODO: Manage SSH username and password.
resource "unifi_setting_mgmt" "default" {
  auto_upgrade = false
  ssh_enabled  = var.ssh_config.username != ""

  dynamic "ssh_key" {
    for_each = var.ssh_config.keys

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
