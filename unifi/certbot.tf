locals {
  certbot_config = {
    cloud_key = {
      domain = var.certbot.domains.network
      host   = "unifi_network_controller"
    }

    nas = {
      domain = var.certbot.domains.drive
      host   = "unifi_drive_nas"
    }

    nvr = {
      domain = var.certbot.domains.protect
      host   = "unifi_protect_nvr"
    }
  }
}

data "remote_file" "version" {
  conn {
    host     = var.clients[each.value.host].fixed_ip
    user     = "root"
    password = var.ssh_config.password
  }

  path = "/usr/lib/version"

  for_each = local.certbot_config
}

resource "terraform_data" "certbot" {
  triggers_replace = [
    data.remote_file.version[each.key],
  ]

  connection {
    type     = "ssh"
    user     = "root"
    password = var.ssh_config.password
    host     = var.clients[each.value.host].fixed_ip
  }

  provisioner "remote-exec" {
    inline = [
      format(
        "test -f .acme.sh/acme.sh || %s",
        format("curl https://get.acme.sh | sh -s email=%s", var.certbot.email),
      ),

      # Enable auto-upgrade.
      format(
        ".acme.sh/acme.sh --info | grep --extended-regexp --quiet \"^AUTO_UPGRADE=['\\\"]?1['\\\"]?$\" || %s",
        ".acme.sh/acme.sh --upgrade --auto-upgrade",
      ),

      # Enable cronjob.
      "crontab -l 2>/dev/null || .acme.sh/acme.sh --install-cronjob",

      # Issue and deploy certificate.
      ".acme.sh/acme.sh --server letsencrypt --set-default-ca",

      format(
        "test -d .acme.sh/%s || (%s && %s)",
        each.value.domain,
        format(
          "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s .acme.sh/acme.sh --dns dns_aws --domain %s --issue --keylength 4096",
          var.certbot.credentials.aws_access_key_id,
          nonsensitive(var.certbot.credentials.aws_secret_access_key),
          each.value.domain,
        ),
        format(
          ".acme.sh/acme.sh --deploy --deploy-hook unifi --domain %s",
          each.value.domain,
        ),
      ),
    ]
  }

  for_each = local.certbot_config
}
