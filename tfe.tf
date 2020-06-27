resource "tfe_organization" "main" {
  name                     = "spence"
  email                    = gsuite_user.main["josh"].primary_email
  collaborator_auth_policy = "two_factor_mandatory"
}

resource "tfe_workspace" "home" {
  name         = "home"
  organization = tfe_organization.main.name
  operations   = false
}

resource "tfe_workspace" "home_k8s" {
  name         = "home-k8s"
  organization = tfe_organization.main.name
  operations   = false
}
