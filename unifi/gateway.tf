# TODO: Configure port overrides.
resource "unifi_device" "gateway" {
  name = "Gateway"

  lifecycle {
    ignore_changes = [port_override]
  }
}
