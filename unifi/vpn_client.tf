locals {
  # See https://nordvpn.com/servers/tools/.
  nordvpn_server_filters = {
    country_id          = 228  # United States
    server_groups       = [11] # Standard VPN
    server_technologies = [3]  # UDP
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

locals {
  dnsmasq_conf_d = "/run/dnsmasq.conf.d"
  splitvpn_base  = "/mnt/data/split-vpn"
  nordvpn_base   = "${local.splitvpn_base}/nordvpn"

  nordvpn_auth    = "${local.nordvpn_base}/auth.txt"
  nordvpn_conf    = "${local.nordvpn_base}/vpn.conf"
  nordvpn_device  = "tun0"
  nordvpn_dnsmasq = "${local.nordvpn_base}/dnsmasq.conf"
  nordvpn_ovpn    = "${local.nordvpn_base}/nordvpn.ovpn"
  nordvpn_pid     = "/run/openvpn-nordvpn.pid"

  nordvpn_config = {
    forced_source_interface   = ""
    forced_source_ipv4        = ""
    forced_source_ipv6        = ""
    forced_source_mac         = ""
    forced_destinations_ipv4  = ""
    forced_destinations_ipv6  = ""
    forced_local_interface    = ""
    exempt_source_ipv4        = ""
    exempt_source_ipv6        = ""
    exempt_source_mac         = ""
    exempt_destinations_ipv4  = ""
    exempt_destinations_ipv6  = ""
    forced_ipsets             = formatlist("%s:dst", local.netflix_ipsets)
    exempt_ipsets             = ""
    dns_ipv4_ip               = "DHCP"
    dns_ipv4_port             = 53
    dns_ipv4_interface        = ""
    dns_ipv6_ip               = ""
    dns_ipv6_port             = 53
    dns_ipv6_interface        = ""
    bypass_masquerade_ipv4    = ""
    bypass_masquerade_ipv6    = ""
    killswitch                = 0
    remove_killswitch_on_exit = 1
    remove_startup_blackholes = 1
    vpn_provider              = "openvpn"
    gateway_table             = "auto"
    watcher_timer             = 1
    route_table               = 101
    mark                      = "0x169"
    prefix                    = "VPN_"
    pref                      = 99
    dev                       = local.nordvpn_device
  }

  netflix_domains    = ["netflix.com", "netflix.net", "nflxext.com", "nflximg.com", "nflxso.net", "nflxvideo.net"]
  netflix_ipset_ipv4 = "netflix_ipv4"
  netflix_ipset_ipv6 = "netflix_ipv6"
  netflix_ipsets     = [local.netflix_ipset_ipv4, local.netflix_ipset_ipv6]
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
    content     = join("\n", [for key, value in local.nordvpn_config : format("%s=%s", upper(key), jsonencode(join(" ", flatten([value]))))])
    destination = local.nordvpn_conf
  }

  file {
    content     = format("ipset=/%s/%s\n", join("/", local.netflix_domains), join(",", local.netflix_ipsets))
    destination = local.nordvpn_dnsmasq
  }

  file {
    content     = data.http.nordvpn_config.response_body
    destination = local.nordvpn_ovpn
  }
}
