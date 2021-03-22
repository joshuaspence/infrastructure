resource "unifi_device" "access_point" {
  name = "UAP-nanoHD"
}

resource "unifi_device" "gateway" {
  name = "USG-Pro-4"
}

resource "unifi_device" "switch" {
  name = "US-24-250W"
}
