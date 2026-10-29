data "unifi_client_qos_rate" "default" {
  name = "Default"
}

resource "unifi_site" "default" {
  description = "Home"
}

# TODO: Manage SSH username and password.
resource "unifi_setting" "default" {
  auto_speedtest = {
    enabled   = true
    cron_expr = "0 4 * * *"
  }

  country = {
    code = 36
  }

  dpi = {
    enabled                = true
    fingerprinting_enabled = true
  }

  mgmt = {
    auto_upgrade = {
      enabled = false
    }

    ssh = {
      enabled = var.ssh_config.username != ""

      keys = [
        for key in var.ssh_config.keys : {
          name    = key.name
          type    = key.type
          comment = key.comment
          key     = key.key
        }
      ]
    }
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
