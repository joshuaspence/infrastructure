# TODO: Manage alias domains.
resource "gsuite_domain" "main" {
  domain_name = var.primary_domain
}

variable "gsuite_users" {
  type = map(object({
    family_name = string
    given_name  = string
  }))
}

resource "gsuite_user" "main" {
  name          = each.value
  primary_email = format("%s@%s", each.key, gsuite_domain.main.domain_name)
  for_each      = var.gsuite_users

  # TODO: Remove this.
  lifecycle {
    ignore_changes = [recovery_email, recovery_phone]
  }
}

variable "gsuite_group_members" {
  type = object({
    dmarc_reports = map(string)
    shopping_list = map(string)
  })
}

resource "gsuite_group" "dmarc_reports" {
  email = format("dmarc@%s", gsuite_domain.main.domain_name)
  name  = "DMARC Reports"
}

resource "gsuite_group_settings" "dmarc_reports" {
  email                          = gsuite_group.dmarc_reports.email
  allow_external_members         = true
  include_in_global_address_list = false
}

resource "gsuite_group_members" "dmarc_reports" {
  group_email = gsuite_group.dmarc_reports.email

  dynamic "member" {
    for_each = var.gsuite_group_members.dmarc_reports

    content {
      role  = member.value
      email = gsuite_user.main[member.key].primary_email
    }
  }
}

resource "gsuite_group" "shopping_list" {
  email = format("shopping-list@%s", gsuite_domain.main.domain_name)
  name  = "OurGroceries"
}

resource "gsuite_group_members" "shopping_list" {
  group_email = gsuite_group.shopping_list.email

  dynamic "member" {
    for_each = var.gsuite_group_members.shopping_list

    content {
      role  = member.value
      email = gsuite_user.main[member.key].primary_email
    }
  }
}
