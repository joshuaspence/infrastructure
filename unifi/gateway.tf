# TODO: Configure port overrides.
resource "unifi_device" "gateway" {
  name = "Gateway"

  lifecycle {
    ignore_changes = [port_override]
  }
}

locals {
  gateway_boot_scripts = {
    multicast-relay = format(
      <<-EOT
        podman image exists scyto/multicast-relay:latest || podman build --file https://gist.github.com/joshuaspence/b3735676129eac88de8f2e97b1a9d081/raw/Dockerfile --tag docker.io/scyto/multicast-relay:latest .
        podman container exists multicast-relay || podman create --detach --name multicast-relay --network host --restart always scyto/multicast-relay:latest %s
        podman start multicast-relay
      EOT
      ,
      format(
        "python3 /multicast-relay/multicast-relay.py --interfaces %s --relay %s --noMDNS --noSSDP --noSonosDiscovery --foreground",
        join(" ", [for network in unifi_network.network : network.subnet if network.purpose != "guest"]),
        join(" ", [for device_discovery in local.device_discovery : format("255.255.255.255:%d", device_discovery.broadcast_port)]),
      ),
    )
  }
}

# NOTE: I can't use the `remote_file` resource due to golang/go#8657.
resource "ssh_resource" "gateway" {
  host  = "gateway"
  user  = var.ssh_config.username
  agent = true

  dynamic "file" {
    for_each = local.gateway_boot_scripts

    content {
      content     = <<-EOT
        #!/bin/sh

        set -e
        set -u
        set -o pipefail

        ${file.value}
      EOT
      destination = "/mnt/data/on_boot.d/${file.key}.sh"
      permissions = "0755"
    }
  }
}
