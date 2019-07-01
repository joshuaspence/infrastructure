resource "gsuite_domain" "main" {
  domain_name = local.domains[0].name
}

resource "gsuite_user" "josh" {
  name = {
    family_name = "Spence"
    given_name  = "Joshua"
  }

  primary_email = format("josh@%s", gsuite_domain.main.domain_name)
}
