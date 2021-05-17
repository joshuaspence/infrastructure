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

  # TODO: Move this to a variable.
  port_override {
    number          = 1
    port_profile_id = "60375bd8ddb88d01485711a7"
  }

  port_override {
    number          = 2
    port_profile_id = "60375bd8ddb88d01485711a7"
  }

  port_override {
    number          = 3
    port_profile_id = "60375bd8ddb88d01485711a7"
  }
}
