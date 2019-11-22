aws_account_id = "287139315271"
aws_profile    = "personal"
aws_region     = "ap-southeast-2"

gsuite_credentials_file        = "~/.gsuite/personal.json"
gsuite_impersonated_user_email = "josh@joshuaspence.com"

domains = {
  "joshuaspence.com" = {
    dkim = {
      public_key = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC+NreQPu/w8G6yacO/UFBo8TA1sWhStJDtDkeelHymiNuDKTsq5zckGhrqxBjKOnVgDxE5rbdTL5ByS8bHnF0AgtXAKUkuNBfNpkUaud0hbW1qbVy7ijn629KKKJ/NzuoAUtO+EfJWoWeNfK/AT3Ipe84NyjolVmbPP66lm6vxFwIDAQAB"
    }

    google_site_verification = {
      key   = "a6bfmanqta6v"
      value = "7cfhlaayo7k56n"
    }
  }

  "joshuaspence.com.au" = {
    dkim = {
      public_key = "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCAjWainf+pFKnIfV50dzBD6xuxK5+mZSdZ0iWJ3nyf5TKhdnkiRn/6yvgVIqxLQUAZijNonliq6Sjw9ZSd9HWGJHWiMNXmOfjiqkCnLpZcPrVYPnG+YLhznNcF0/5Y3mRU4r/BCQlNz95k6Z88gJ7aX6t3zZr/VPekhasgWLztWQIDAQAB"
    }

    google_site_verification = {
      key   = "wbgozhdmu5fo"
      value = "ck24ekzqntivoz"
    }
  }
}

kubernetes_config_context = "minikube"
primary_domain            = "joshuaspence.com"

home_assistant_config = {
  host    = "home-assistant.local"
  version = "0.101.0"
}

unifi_config = {
  host     = "unifi.local"
  timezone = "Australia/Sydney"
  version  = "5.12.22"
}

velero_config = {
  bucket         = "spence-velero"
  plugin_version = "1.0.0"
  version        = "1.2.0"
}
