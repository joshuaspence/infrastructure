locals {
  # See https://nordvpn.com/servers/tools/.
  nordvpn_server_filters = {
    country_id          = 228
    server_groups       = [11]
    server_technologies = [3]
  }
}

data "http" "nordvpn_servers" {
  url = format("https://nordvpn.com/wp-admin/admin-ajax.php?action=servers_recommendations&filters=%s", jsonencode(local.nordvpn_server_filters))
}

resource "random_shuffle" "nordvpn_server" {
  input        = [for server in jsondecode(data.http.nordvpn_servers.response_body) : server.hostname]
  keepers      = { for key, value in local.nordvpn_server_filters : key => jsonencode(value) }
  result_count = 1

  lifecycle {
    ignore_changes = [input]
  }
}

data "http" "nordvpn_config" {
  url = format("https://downloads.nordcdn.com/configs/files/ovpn_%s/servers/%s.%s.ovpn", "udp", random_shuffle.nordvpn_server.result[0], "udp")
}

data "http" "netflix_asn" {
  url = "https://mxtoolbox.com/api/v1/lookup/asn/2906"

  request_headers = {
    Authorization = var.mxtoolbox_api_key
  }
}

locals {
  splitvpn_base = "/mnt/data/split-vpn"
  nordvpn_base  = "${local.splitvpn_base}/nordvpn"

  nordvpn_auth   = "${local.nordvpn_base}/auth.txt"
  nordvpn_conf   = "${local.nordvpn_base}/vpn.conf"
  nordvpn_device = "tun0"
  nordvpn_ovpn   = "${local.nordvpn_base}/nordvpn.ovpn"
  nordvpn_pid    = "${local.nordvpn_base}/openvpn.pid"
}

# NOTE: I can't use the `remote_file` resource due to golang/go#8657.
resource "ssh_resource" "gateway_nordvpn" {
  host  = format("gateway.%s", var.networks["management"].domain_name)
  user  = var.ssh_config.username
  agent = true

  pre_commands = [
    "mkdir --parents ${local.splitvpn_base}",
    "mkdir --parents ${local.nordvpn_base}",
  ]

  file {
    content     = format("%s\n%s\n", var.nordvpn_auth.username, var.nordvpn_auth.password)
    destination = local.nordvpn_auth
    permissions = "0600"
  }

  file {
    content     = data.http.nordvpn_config.response_body
    destination = local.nordvpn_ovpn
  }

  file {
    content = format(
      <<-EOT
        FORCED_SOURCE_INTERFACE=""
        FORCED_SOURCE_IPV4=""
        FORCED_SOURCE_IPV6=""
        FORCED_SOURCE_MAC=""
        FORCED_DESTINATIONS_IPV4="%s"
        FORCED_DESTINATIONS_IPV6=""
        FORCED_LOCAL_INTERFACE=""
        EXEMPT_SOURCE_IPV4=""
        EXEMPT_SOURCE_IPV6=""
        EXEMPT_SOURCE_MAC=""
        EXEMPT_DESTINATIONS_IPV4=""
        EXEMPT_DESTINATIONS_IPV6=""
        FORCED_IPSETS=""
        EXEMPT_IPSETS=""
        DNS_IPV4_IP="DHCP"
        DNS_IPV4_PORT=53
        DNS_IPV4_INTERFACE=""
        DNS_IPV6_IP=""
        DNS_IPV6_PORT=53
        DNS_IPV6_INTERFACE=""
        BYPASS_MASQUERADE_IPV4=""
        BYPASS_MASQUERADE_IPV6=""
        KILLSWITCH=0
        REMOVE_KILLSWITCH_ON_EXIT=1
        REMOVE_STARTUP_BLACKHOLES=1
        VPN_PROVIDER="openvpn"
        GATEWAY_TABLE="auto"
        WATCHER_TIMER=1
        ROUTE_TABLE=101
        MARK=0x169
        PREFIX="VPN_"
        PREF=99
        DEV=%s
      EOT
      ,
      join(" ", [for info in jsondecode(data.http.netflix_asn.response_body).Information : info["CIDR Range"]]),
      local.nordvpn_device,
    )
    destination = local.nordvpn_conf
  }
}
