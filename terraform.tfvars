aws_account_id = "287139315271"
aws_profile    = "personal"
aws_region     = "ap-southeast-2"

google_credentials_file        = "~/.gsuite/personal.json"
google_impersonated_user_email = "josh@joshuaspence.com"

domains = {
  "joshuaspence.com" = {
    dkim = {
      public_key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwrXHtW9q5xyPkIn04BYd5Y8NUfqnPMV0m1bIYI4eRxrRhXd4fCkfqUagk2Hq5LueK3rIZZxAnLr+JE+P/yc88o9mw6sJRjYziAl3gPpazQN9M19MWzXrMCg173UQW8roifseeKyxYordE0qfruuKWRv+5SW7Q7S6VVcCkWnh0iRGP0tHBXwsHXJbIILwKKe9Ktu3kVidp4NoUE5zTSZ4xb/f9FhEMbsigzAKoOmjqUECLVOizPWdGOitJgts/NfpVl5Hzg5RrEcbIHXjAXUGhfaUWgsEzCl3AIGtPm0d2Wo2tvI7NV+toNA3vq6w+o1ahQ4t5E7r5RDmC+GKaSui8QIDAQAB"
    }

    github_pages_verification = {
      value = "8240bb71daf590e7740564358ef5f1"
    }

    google_site_verification = {
      key   = "a6bfmanqta6v"
      value = "7cfhlaayo7k56n"
    }
  }

  "spence.com.au" = {}

  "spence.family" = {
    dkim = {
      public_key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAq61MZIowkam1HHRMzd67r/kWIFLa4v4Z6Wd5QTbSMu91IafFmCVRuaMe2Vrf3VuBcQhL1dqgIJHVN+tyYpB3UB5o5X7sP/keX8t6S/fi9H6gnQz5RvAk2qSMFC34KIBJGs5I2U/dzMip4wXHkuEOEtngZnC++WJLtC34bbtPaAXd6ychEaevMfEXbW5Fv5V/cac8me4QLIIAC8Tjj6yQ+G9fn3lhdRpQoIZiLJVFmZMgftoyxhkeqRwaeCxxrZHhRsN0Y8SWOvCzGKePN5CUF+4tYeB728fFeZTqHULj4Cc5NnogdFMuynC1Wd2M7S+Y0hyMvj8XL1JLC2011YURAQIDAQAB"
    }

    github_pages_verification = {
      value = "86c5c0313c954cb8d87478f40b6507"
    }

    google_site_verification = {
      key   = "dkxbd6ayrn2v"
      value = "mbz5rfkvm54ygt"
    }
  }

  "spence.network" = {
    dkim = {
      public_key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEArJayHFIe8sCPC5ZejP3kCrx9QpJvBkb+rLR3TR9RlL8jtzsYHT9jWWSfhycc9d5JxPr95VudoUJ1hS/WUX19rmFp3GBJVf/YAA9nbusGTBEgdBdiXMfyPf7fx0KjUqy/eihnAuVFiW3+gwbNS1c/yC8miArVBGAS+kyfrHFo3Wfv5Vinz3vYxh21jpdQvLrqSCxwW5s/dQjbG82v+HxbWXohwbVsmvamX3n8TLIGxTDH4No1igCagK9pCvs5azKJocxbCQh5QZQbkGP8Ew7WaRTuXucWycIcy2oRMkGlslscPbaysFc/+7QUqdifZK8qsqEbe/o+iWVRKtQqVLCktwIDAQAB"
    }

    github_pages_verification = {
      value = "2eb8f97e2b7efb7014335b37e3c430"
    }

    google_site_verification = {
      key   = "mppc52chhwxw"
      value = "jk7rvyosvozhpf"
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

  shopping_list = {
    josh = "OWNER"
  }

  sysadmin = {
    josh = "OWNER"
  }
}

primary_domain = "joshuaspence.com"

unifi_switch_port_overrides = {
  1 = {
    profile = "poe_disabled"
  }

  3 = {
    profile = "poe_disabled"
  }

  4 = {
    profile = "iot_network"
  }

  5 = {
    profile = "poe_disabled"
  }

  23 = {
    profile = "not_network"
  }

  24 = {
    profile = "not_network"
  }
}
