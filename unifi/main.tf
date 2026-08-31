data "unifi_ap_group" "default" {
  name = "All APs"
}

resource "unifi_ap_group" "ceiling" {
  name        = "Ceiling"
  device_macs = [for key, device in var.access_points : device.mac if contains(["hallway", "kitchen"], key)]
}

resource "unifi_ap_group" "wall" {
  name        = "Wall"
  device_macs = [for key, device in var.access_points : device.mac if !contains(["hallway", "kitchen"], key)]
}

data "unifi_client_qos_rate" "default" {
  name = "Default"
}

resource "unifi_site" "default" {
  description = "Home"
}

# TODO: Manage SSH username and password.
resource "unifi_setting" "default" {
  mgmt = {
    auto_upgrade = false
    ssh_enabled  = var.ssh_config.username != ""

    ssh_keys = [
      for key in var.ssh_config.keys : {
        name    = key.name
        type    = key.type
        comment = key.comment
        key     = key.key
      }
    ]
  }

  radius = {
    secret = var.vpn.secret
  }
}

# The Cloud Key is a "client" rather than a "device", so the SSH settings in `unifi_setting.default` aren't applied to it.
resource "remote_file" "cloud_key_ssh" {
  provider = remote.cloud_key
  path     = "/root/.ssh/authorized_keys"
  content  = join("\n", [for key in var.ssh_config.keys : format("%s %s %s", key.type, key.key, key.comment)])
}

# The UNVR is a "client" rather than a "device", so the SSH settings in `unifi_setting.default` aren't applied to it.
resource "remote_file" "nvr_ssh" {
  provider = remote.nvr
  path     = "/root/.ssh/authorized_keys"
  content  = join("\n", [for key in var.ssh_config.keys : format("%s %s %s", key.type, key.key, key.comment)])
}
