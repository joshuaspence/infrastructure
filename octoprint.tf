resource "terraform_data" "octoprint_certbot" {
  connection {
    type        = "ssh"
    user        = "root"
    host        = aws_route53_record.unifi_client["octoprint"].fqdn
    private_key = file(pathexpand("~/.ssh/keys/rpi.key"))
  }

  provisioner "remote-exec" {
    inline = [
      format(
        "test -f .acme.sh/acme.sh || %s",
        format("curl https://get.acme.sh | sh -s email=%s", format("josh@%s", googleworkspace_domain.secondary["spence.network"].domain_name)),
      ),

      # Enable auto-upgrade.
      format(
        ".acme.sh/acme.sh --info | grep --extended-regexp --quiet \"^AUTO_UPGRADE=['\\\"]?1['\\\"]?$\" || %s",
        ".acme.sh/acme.sh --upgrade --auto-upgrade",
      ),

      # Enable cronjob.
      "crontab -l 2>/dev/null || .acme.sh/acme.sh --install-cronjob",

      # Issue and deploy certificate.
      ".acme.sh/acme.sh --server letsencrypt --set-default-ca --force",

      format(
        "test -d .acme.sh/%s || (%s && %s)",
        aws_route53_record.unifi_client["octoprint"].fqdn,
        format(
          "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s .acme.sh/acme.sh --dns dns_aws --domain %s --issue",
          aws_iam_access_key.certbot.id,
          nonsensitive(aws_iam_access_key.certbot.secret),
          aws_route53_record.unifi_client["octoprint"].fqdn,
        ),
        format(
          ".acme.sh/acme.sh --deploy --deploy-hook haproxy --domain %s",
          aws_route53_record.unifi_client["octoprint"].fqdn,
        ),
      ),
    ]
  }
}

