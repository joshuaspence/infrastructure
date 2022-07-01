# The UNVR is a "client" rather than a "device", so the SSH settings in `unifi_setting_mgmt.default` aren't applied to it.
resource "remote_file" "nvr_ssh" {
  provider = remote.nvr
  path     = "/root/.ssh/authorized_keys"
  content  = join("\n", [for key in var.ssh_config.keys : format("%s %s %s", key.type, key.key, key.comment)])
}
