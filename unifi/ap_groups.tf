data "unifi_ap_group" "default" {
  name = "All APs"
}

resource "unifi_ap_group" "ceiling" {
  name        = "Ceiling"
  device_macs = [for key, device in var.access_points : device.mac if contains(device.tags, "ceiling")]
}

resource "unifi_ap_group" "downstairs" {
  name        = "Downstairs"
  device_macs = [for key, device in var.access_points : device.mac if contains(device.tags, "downstairs")]
}

resource "unifi_ap_group" "upstairs" {
  name        = "Upstairs"
  device_macs = [for key, device in var.access_points : device.mac if contains(device.tags, "upstairs")]
}

resource "unifi_ap_group" "wall" {
  name        = "Wall"
  device_macs = [for key, device in var.access_points : device.mac if contains(device.tags, "wall")]
}
