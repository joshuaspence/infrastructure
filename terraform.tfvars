aws_account_id = "287139315271"
aws_profile    = "personal"
aws_region     = "ap-southeast-2"

gsuite_credentials_file        = "~/.gsuite/personal.json"
gsuite_impersonated_user_email = "josh@joshuaspence.com"

domains = {
  "joshuaspence.com" = {
    dkim = {
      public_key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwrXHtW9q5xyPkIn04BYd5Y8NUfqnPMV0m1bIYI4eRxrRhXd4fCkfqUagk2Hq5LueK3rIZZxAnLr+JE+P/yc88o9mw6sJRjYziAl3gPpazQN9M19MWzXrMCg173UQW8roifseeKyxYordE0qfruuKWRv+5SW7Q7S6VVcCkWnh0iRGP0tHBXwsHXJbIILwKKe9Ktu3kVidp4NoUE5zTSZ4xb/f9FhEMbsigzAKoOmjqUECLVOizPWdGOitJgts/NfpVl5Hzg5RrEcbIHXjAXUGhfaUWgsEzCl3AIGtPm0d2Wo2tvI7NV+toNA3vq6w+o1ahQ4t5E7r5RDmC+GKaSui8QIDAQAB"
    }

    google_site_verification = {
      key   = "a6bfmanqta6v"
      value = "7cfhlaayo7k56n"
    }
  }

  "joshuaspence.com.au" = {
    dkim = {
      public_key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAjlEsrW+9/6VDQMpawsOhqLBilFAbRRnKZ4BQL62wM56aef3USRFHV7P+VuzUN7aFxtxWYGsWXia8q8e1tppGgv+c7unAcYymzgKYa1271pCUV57OoH7iehiQxVQ3tvXaeGYF+I+H8CeZTKoD4ukD6bsX1lzx16Tve3+0aR3xhImLb9ezzHYLZkyilY47+LbLbuOwUU9RxJsQGg1O41hg15RvFDJrNEnSj3eLeg6V/k9ZbQ8jVeiryEXdPAhBKSmeACCUmpIYL0HXzTAD5ABXIgdC4jUgdqvgUSut8LW2yTXxbHHFfQ13YwbNLEUuJr3XG9sx8c74CNSg0qgkN+4FAwIDAQAB"
    }

    google_site_verification = {
      key   = "wbgozhdmu5fo"
      value = "ck24ekzqntivoz"
    }
  }
}

gsuite_users = {
  josh = {
    given_name  = "Joshua"
    family_name = "Spence"
  }
}

gsuite_group_members = {
  dmarc_reports = {
    josh = "OWNER"
  }
}

kubernetes_config_context = "minikube"
primary_domain            = "joshuaspence.com"

home_assistant_config = {
  host    = "home-assistant.local"
  version = "0.103.0"
}

unifi_config = {
  host     = "unifi.local"
  timezone = "Australia/Sydney"
  version  = "5.12.35"
}

velero_config = {
  bucket         = "spence-velero"
  plugin_version = "1.0.0"
  version        = "1.2.0"
}
