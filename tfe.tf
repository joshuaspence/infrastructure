resource "tfe_organization" "main" {
  name                     = "spence"
  email                    = googleworkspace_user.main["josh"].primary_email
  collaborator_auth_policy = "two_factor_mandatory"
}

resource "tfe_organization_token" "github_actions" {
  organization = tfe_organization.main.name
}

resource "tfe_workspace" "home" {
  name         = "home"
  organization = tfe_organization.main.name
  operations   = false
}
