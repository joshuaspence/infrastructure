# TODO: Configure port overrides.
resource "unifi_device" "gateway" {
  name = "Gateway"

  lifecycle {
    ignore_changes = [port_override]
  }
}

data "http" "multicast_relay" {
  url = "https://raw.githubusercontent.com/joshuaspence/multicast-relay/optional-http/multicast-relay.py"
}

resource "remote_file" "multicast_relay" {
  provider    = remote.gateway
  path        = "/usr/local/bin/multicast-relay"
  content     = data.http.multicast_relay.response_body
  permissions = "0755"
}

resource "remote_file" "multicast_relay_config" {
  provider = remote.gateway
  path     = "/etc/default/multicast-relay"
  content = format(
    <<-EOT
      INTERFACES=%s
      RELAY=%s
    EOT
    ,
    join(" ", [for network in unifi_network.network : network.subnet if network.purpose != "guest"]),
    join(" ", [for device_discovery in local.device_discovery : format("255.255.255.255:%d", device_discovery.broadcast_port)]),
  )
}

resource "remote_file" "multicast_relay_service" {
  provider = remote.gateway
  path     = "/etc/systemd/system/multicast-relay.service"

  content = <<-EOT
    [Unit]
    Description=Multicast and broadcast packet relay
    Documentation=https://github.com/alsmith/multicast-relay
    Wants=udapi-server.service
    After=udapi-server.service

    [Service]
    ExecStart=/usr/local/bin/multicast-relay --interfaces $INTERFACES --relay $RELAY --noMDNS --noSSDP --noSonosDiscovery --homebrewNetifaces --foreground --homebrewNetifaces
    Restart=on-failure
    DynamicUser=true
    AmbientCapabilities=CAP_NET_RAW
    EnvironmentFile=/etc/default/%p

    [Install]
    WantedBy=multi-user.target
  EOT
}

resource "terraform_data" "multicast_relay_systemd" {
  triggers_replace = {
    config  = remote_file.multicast_relay_config.content
    script  = remote_file.multicast_relay.content
    service = remote_file.multicast_relay_service.content
  }

  connection {
    type     = "ssh"
    user     = var.ssh_config.username
    password = var.ssh_config.password
    host     = format("gateway.%s", var.networks["management"].domain_name)
  }

  provisioner "remote-exec" {
    inline = [
      "systemctl daemon-reload",
      "systemctl enable --now multicast-relay.service",
    ]
  }
}
