resource "gsuite_domain" "main" {
  domain_name = local.primary_domain
}

resource "gsuite_user" "josh" {
  name = {
    family_name = "Spence"
    given_name  = "Joshua"
  }

  primary_email = format("josh@%s", gsuite_domain.main.domain_name)
}

# NOTE: I wanted the email address for this group to be
# `postmaster@joshuaspence.com` but `postmaster@...` is reserved,
# see https://support.google.com/a/answer/33389?hl=en.
resource "gsuite_group" "postmaster" {
  email = format("mailauth-reports@%s", gsuite_domain.main.domain_name)
  name  = "Postmaster"
}

resource "gsuite_group_members" "postmaster" {
  group_email = gsuite_group.postmaster.email

  member {
    role  = "OWNER"
    email = gsuite_user.josh.primary_email
  }
}
