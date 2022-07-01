# The Cloud Key is a "client" rather than a "device", so the SSH settings in `unifi_setting_mgmt.default` aren't applied to it.
resource "remote_file" "cloud_key_ssh" {
  provider = remote.cloud_key
  path     = "/root/.ssh/authorized_keys"
  content  = join("\n", [for key in var.ssh_config.keys : format("%s %s %s", key.type, key.key, key.comment)])
}

# TODO: Move this to gateway.
resource "null_resource" "cloud_key_certbot" {
  connection {
    type     = "ssh"
    user     = var.ssh_config.username
    password = var.ssh_config.password
    host     = var.clients["unifi_network_controller"].fixed_ip
  }

  provisioner "remote-exec" {
    inline = [
      format(
        "test -f .acme.sh/acme.sh || curl https://get.acme.sh | sh -s email=%s",
        var.certbot.email,
      ),
      ".acme.sh/acme.sh --server letsencrypt --set-default-ca",
      format(
        "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s .acme.sh/acme.sh --dns dns_aws --domain %s --issue",
        var.certbot.credentials.aws_access_key_id,
        var.certbot.credentials.aws_secret_access_key,
        var.certbot.domain,
      ),
      format(
        ".acme.sh/acme.sh --deploy --deploy-hook unifi --domain %s",
        var.certbot.domain,
      ),
    ]
  }
}
