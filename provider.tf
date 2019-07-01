provider "aws" {
  region              = "ap-southeast-2"
  profile             = "personal"
  allowed_account_ids = ["287139315271"]
}

provider "gsuite" {
  credentials             = pathexpand("~/.gsuite/personal-245112-62ef53c394de.json")
  impersonated_user_email = "josh@joshuaspence.com"

  oauth_scopes = [
    "https://www.googleapis.com/auth/admin.directory.domain",
    "https://www.googleapis.com/auth/admin.directory.group",
    "https://www.googleapis.com/auth/admin.directory.user",
  ]
}
