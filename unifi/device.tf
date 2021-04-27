resource "unifi_device" "hallway_access_point" {
  name = "Hallway Access Point"
}

resource "unifi_device" "kitchen_access_point" {
  name = "Kitchen Access Point"
}

resource "unifi_device" "gateway" {
  name = "Gateway"
}

resource "unifi_device" "switch" {
  name = "Switch"
}
