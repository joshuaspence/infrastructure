locals {
  nordvpn_api               = "https://api.nordvpn.com/v1"
  nordvpn_server_country    = "United States"
  nordvpn_server_group      = "legacy_standard"
  nordvpn_server_technology = "openvpn_udp"

  nordvpn_server_filters = {
    country    = one([for country in jsondecode(data.http.nordvpn_server_countries.response_body) : country.id if country.name == local.nordvpn_server_country])
    group      = one([for group in jsondecode(data.http.nordvpn_server_groups.response_body) : group.identifier if group.identifier == local.nordvpn_server_group])
    technology = one([for technology in jsondecode(data.http.nordvpn_server_technologies.response_body) : technology.identifier if technology.identifier == local.nordvpn_server_technology])
  }
}

data "http" "nordvpn_server_countries" {
  url = "${local.nordvpn_api}/servers/countries"
}

data "http" "nordvpn_server_groups" {
  url = "${local.nordvpn_api}/servers/groups"
}

data "http" "nordvpn_server_technologies" {
  url = "${local.nordvpn_api}/technologies"
}

data "http" "nordvpn_servers" {
  url = format(
    "%s/servers/recommendations?%s&limit=128",
    local.nordvpn_api,
    join(
      "&",
      [
        "filters[country_id]=${local.nordvpn_server_filters.country}",
        "filters[servers_groups][identifier]=${local.nordvpn_server_filters.group}",
        "filters[servers_technologies][identifier]=${local.nordvpn_server_filters.technology}",
      ],
    ),
  )
}

data "http" "nordvpn_certificate" {
  url = "https://downloads.nordcdn.com/certificates/root.pem"
}

locals {
  nordvpn_tls_key = <<-EOT
    -----BEGIN OpenVPN Static key V1-----
    e685bdaf659a25a200e2b9e39e51ff03
    0fc72cf1ce07232bd8b2be5e6c670143
    f51e937e670eee09d4f2ea5a6e4e6996
    5db852c275351b86fc4ca892d78ae002
    d6f70d029bd79c4d1c26cf14e9588033
    cf639f8a74809f29f72b9d58f9b8f5fe
    fc7938eade40e9fed6cb92184abb2cc1
    0eb1a296df243b251df0643d53724cdb
    5a92a1d6cb817804c4a9319b57d53be5
    80815bcfcb2df55018cc83fc43bc7ff8
    2d51f9b88364776ee9d12fc85cc7ea5b
    9741c4f598c485316db066d52db4540e
    212e1518a9bd4828219e24b20d88f598
    a196c9de96012090e333519ae18d3509
    9427e7b372d348d352dc4c85e18cd4b9
    3f8a56ddb2e64eb67adfc9b337157ff4
    -----END OpenVPN Static key V1-----
  EOT
}

resource "random_shuffle" "nordvpn_server" {
  input        = [for server in jsondecode(data.http.nordvpn_servers.response_body) : server.hostname]
  keepers      = local.nordvpn_server_filters
  result_count = 64

  lifecycle {
    ignore_changes = [input]
  }
}

output "nordvpn_config" {
  value = format(
    <<-EOT
      client
      dev tun
      resolv-retry infinite
      remote-random
      nobind
      tun-mtu 1500
      tun-mtu-extra 32
      mssfix 1450
      persist-key
      persist-tun
      ping 15
      ping-restart 0
      ping-timer-rem
      reneg-sec 0
      comp-lzo no

      remote-cert-tls server

      auth-user-pass
      verb 3
      pull
      fast-io
      cipher AES-256-CBC
      auth SHA512
      <ca>
      %s
      </ca>
      key-direction 1
      <tls-auth>
      %s
      </tls-auth>
      %s
    EOT
    ,
    trimspace(data.http.nordvpn_certificate.response_body),
    trimspace(local.nordvpn_tls_key),
    join("\n", formatlist("remote %s 1194 udp", sort(random_shuffle.nordvpn_server.result))),
  )
}
