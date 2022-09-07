# TODO: Configure port overrides.
resource "unifi_device" "gateway" {
  name = "Gateway"

  lifecycle {
    ignore_changes = [port_override]
  }
}

locals {
  gateway_boot_scripts = {
    dnsmasq = <<-EOT
      ipset -exist create ${local.netflix_ipset_ipv4} hash:ip family inet
      ipset -exist create ${local.netflix_ipset_ipv6} hash:ip family inet6

      if ! test -e ${local.dnsmasq_conf_d}/nordvpn.conf; then
        ln -s ${local.nordvpn_dnsmasq} ${local.dnsmasq_conf_d}/nordvpn.conf
        killall -q dnsmasq
      fi
    EOT

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

    split-vpn = <<-EOT
      if ! test -d ${local.splitvpn_base}/vpn; then
        curl --fail --location --show-error --silent https://github.com/peacey/split-vpn/archive/main.tar.gz | tar --extract --file - --gzip --directory ${local.splitvpn_base} --strip-components 1 split-vpn-main/vpn
      fi

      if test -f ${local.nordvpn_pid}; then
        xargs kill -USR1 <${local.nordvpn_pid}
        exit
      fi

      openvpn \
        --config ${local.nordvpn_ovpn} \
        --auth-user-pass ${local.nordvpn_auth} \
        --cd ${local.nordvpn_base} \
        --daemon \
        --dev ${local.nordvpn_device} \
        --down ${local.splitvpn_base}/vpn/updown.sh \
        --ping-restart 15 \
        --redirect-gateway def1 \
        --route-noexec \
        --script-security 2 \
        --up ${local.splitvpn_base}/vpn/updown.sh \
        --user nobody \
        --writepid ${local.nordvpn_pid}
    EOT
  }
}

# NOTE: I can't use the `remote_file` resource due to golang/go#8657.
resource "ssh_resource" "gateway" {
  host  = format("gateway.%s", var.networks["management"].domain_name)
  user  = var.ssh_config.username
  agent = true

  dynamic "file" {
    for_each = local.gateway_boot_scripts

    content {
      content     = <<-EOT
        #!/bin/sh

        set -o errexit
        set -o nounset
        set -o pipefail

        ${file.value}
      EOT
      destination = "/mnt/data/on_boot.d/${file.key}.sh"
      permissions = "0755"
    }
  }
}
