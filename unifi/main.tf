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

# The Cloud Key is a "client" rather than a "device", so the SSH settings in `unifi_setting_mgmt.default` aren't applied to it.
resource "remote_file" "cloud_key_ssh" {
  provider = remote.cloud_key
  path     = "/root/.ssh/authorized_keys"
  content  = join("\n", [for key in var.ssh_config.keys : format("%s %s %s", key.type, key.key, key.comment)])
}

# The UNVR is a "client" rather than a "device", so the SSH settings in `unifi_setting_mgmt.default` aren't applied to it.
resource "remote_file" "nvr_ssh" {
  provider = remote.nvr
  path     = "/root/.ssh/authorized_keys"
  content  = join("\n", [for key in var.ssh_config.keys : format("%s %s %s", key.type, key.key, key.comment)])
}
