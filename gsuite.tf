resource "gsuite_domain" "main" {
  domain_name = var.primary_domain
}

resource "gsuite_user" "josh" {
  name = {
    family_name = "Spence"
    given_name  = "Joshua"
  }

  primary_email = format("josh@%s", gsuite_domain.main.domain_name)
}

resource "gsuite_group" "dmarc_reports" {
  email = format("dmarc@%s", gsuite_domain.main.domain_name)
  name  = "DMARC Reports"
}

resource "gsuite_group_settings" "dmarc_reports" {
  email = gsuite_group.dmarc_reports.email
}

resource "gsuite_group_members" "dmarc_reports" {
  group_email = gsuite_group.dmarc_reports.email

  member {
    role  = "OWNER"
    email = gsuite_user.josh.primary_email
  }
}
