aws_account_id = "287139315271"
aws_profile    = "personal"
aws_region     = "ap-southeast-2"

google_credentials_file        = "~/.gsuite/personal.json"
google_impersonated_user_email = "josh@joshuaspence.com"

domains = {
  "spence.com.au" = {
    type = "primary"

    dkim = {
      public_key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAgl76kez+WdfTQ6nq6oPH8vY6h3ROW4H7vtkVBLmMCqRTOccAfQUiKM5qGRQBu638fPKlqIDr+5g2zNyHQBu4nSuvvh0Dfa8UGE/uPUojGPwCACnG3cKwqKtOsH7n+SgF67nI0zQZcfQuLF48KPzeSEbth9TAHsGN+h3x6NUQFZvyJmxLgTd0r+SVjWp927ghvkt7PvV98JbGBrEvui7AzrSDORZcH/Ao9m5FFu24HyLES+G0Pq4Df6SAPdfw10AaNV46pid4xR5NgFU5Dcan3fVRdNltYqwijIKxQ/Gj67iqOwlOtbMsQ+Z9T9pE4wB5vklS6nv7tXsGMwv364PM6wIDAQAB"
    }

    domain_registration = {
      registrar = "aws"
    }

    github_pages_verification = {
      value = "4aa9b01113d2fba7c2bf04ff577d2d"
    }

    google_site_verification = {
      key   = "feniy22i7jfn"
      value = "lex75kgsl5yo3k"
    }
  }

  "joshuaspence.com" = {
    type = "secondary"

    dkim = {
      public_key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwrXHtW9q5xyPkIn04BYd5Y8NUfqnPMV0m1bIYI4eRxrRhXd4fCkfqUagk2Hq5LueK3rIZZxAnLr+JE+P/yc88o9mw6sJRjYziAl3gPpazQN9M19MWzXrMCg173UQW8roifseeKyxYordE0qfruuKWRv+5SW7Q7S6VVcCkWnh0iRGP0tHBXwsHXJbIILwKKe9Ktu3kVidp4NoUE5zTSZ4xb/f9FhEMbsigzAKoOmjqUECLVOizPWdGOitJgts/NfpVl5Hzg5RrEcbIHXjAXUGhfaUWgsEzCl3AIGtPm0d2Wo2tvI7NV+toNA3vq6w+o1ahQ4t5E7r5RDmC+GKaSui8QIDAQAB"
    }

    domain_registration = {
      registrar = "aws"
    }

    github_pages_verification = {
      value = "8240bb71daf590e7740564358ef5f1"
    }

    google_site_verification = {
      key   = "a6bfmanqta6v"
      value = "7cfhlaayo7k56n"
    }
  }

  "spence.au" = {
    type = "alias"

    dkim = {
      public_key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwJ/j7RH5ua6GIfDWG32VBafFExu7RgzMkmEGsSp3+hdd0ws7NVp/+bH9nsb8RwSYAE59+sFlg8bFVhISF7mbP+E2lBLZKGb3DM7O+TdvP3Ruv5ii9K0OBZSzcHaofQLYj+UajsUaq9CJPd+fajMCouD+FDL4gOMCeAgspNxFxV5V31zTiandxDulmYrglcLn4C8NpNYbeAzaJYzKwYttY6dRxzMPYqiNBk4K01Rrcppba04mnj8y9dtYrB/LhnI1f3WGAbfbraouG3tG3hdPVL3y18cKbRTbubJZ5I/GHoD3wMA0B7bf1rmnVuen0MSA6DRqNLxDSUYCHjHGUgyk6QIDAQAB"
    }

    domain_registration = {
      registrar = "aws"
    }

    github_pages_verification = {
      value = "37b0e8d4f71f558b9e0ac7999813b5"
    }

    google_site_verification = {
      key   = "erpybtp6qzc6"
      value = "w2oh3xsm64hv3p"
    }
  }

  "spence.family" = {
    type = "alias"

    dkim = {
      public_key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAh1VTg6mkkhrObiR8mKZnJs+A10cuwljvWnmzTjgJXkQG5iLJOJe/eAllBfMf1KmzTmeW72ccgrm6vco769kJYDj6Z3+aP4ZgkVqwyOCo7Jz5r4v1sm0r1LszPtTVRPPXwhJz25L9snGLuPZLB/zTvDA0BGJYU7WLXT92S2rhXYjHO050wNkm55Pq1nOM+C2kA8rZYeape1svrS1PDhKFe98Ot4aj6FMGYPpBRIikHoHIZSMt2Y0spZUewb9BZtyXFJcj3lxwn17WT05vioZda0ZO0Y+4vwzJMmWZLY1ko6AeWKMEKbqIYINf0/+J2YXZtzRepwcDkeKqNVPGJXInSQIDAQAB"
    }

    domain_registration = {
      registrar = "godaddy"
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
    type = "secondary"

    dkim = {
      public_key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAi84ZTrVdi9NI+V7LYMKNGIsDHrQBgHj3ih0glNhlkQfj4mavxSVjtztx/b/03tb2bW1y1SI6E93+FI6j6qADcSUNgm3b/tCksoMD7ONNyD0r2cbejM30m/3aLPi0dn5Z0RsuAqtKJ4gU20jBRkKjXHLGKYV2ZDmW6b4NrpeOpcyF8vA2mBBIoi+t3tQbeMdx6K2Vi3MR750ehYtLG5pm08luMwOGqiZUeHMyjnwnHnPM/1bTwOHpuxEig1JzHGxOFsZYrlLlBYYzO8B3flqkqDLwl/m7gHQ7xjywNF1wEH3394+iJIFUxF20wi84LUdmG3UOHUUo5QKxUxs9IwvvUwIDAQAB"
    }

    domain_registration = {
      registrar = "aws"
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
    is_admin    = true

    aliases = [
      "%s@joshuaspence.com",
      "%s@spence.network",
    ]
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
