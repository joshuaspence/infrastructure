locals {
  certbot_config = {
    cloud_key = {
      domain = var.certbot.domains.unifi
      host   = "unifi_network_controller"
    }

    nvr = {
      domain = var.certbot.domains.protect
      host   = "unifi_protect_nvr"
    }
  }
}

# TODO: Move this to gateway.
resource "terraform_data" "certbot" {
  connection {
    type     = "ssh"
    user     = var.ssh_config.username
    password = var.ssh_config.password
    host     = var.clients[each.value.host].fixed_ip
  }

  provisioner "remote-exec" {
    inline = [
      "test -f .acme.sh/acme.sh && exit 0",
      format(
        "curl https://get.acme.sh | sh -s email=%s",
        var.certbot.email,
      ),
      ".acme.sh/acme.sh --server letsencrypt --set-default-ca",
      format(
        "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s .acme.sh/acme.sh --dns dns_aws --domain %s --issue",
        var.certbot.credentials.aws_access_key_id,
        nonsensitive(var.certbot.credentials.aws_secret_access_key),
        each.value.domain,
      ),
      format(
        ".acme.sh/acme.sh --deploy --deploy-hook unifi --domain %s",
        each.value.domain,
      ),
    ]
  }

  for_each = local.certbot_config
}
