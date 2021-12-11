# TODO: Manage alias domains.
resource "googleworkspace_domain" "main" {
  domain_name = var.primary_domain
}

variable "gsuite_users" {
  type = map(object({
    family_name = string
    given_name  = string
  }))
}

resource "googleworkspace_user" "main" {
  name {
    family_name = each.value.family_name
    given_name  = each.value.given_name
  }

  primary_email = format("%s@%s", each.key, googleworkspace_domain.main.domain_name)
  for_each      = var.gsuite_users

  # TODO: Remove this.
  lifecycle {
    ignore_changes = [aliases, recovery_email, recovery_phone]
  }
}

variable "gsuite_group_members" {
  type = object({
    dmarc_reports = map(string)
    shopping_list = map(string)
    sysadmin      = map(string)
  })
}

resource "googleworkspace_group" "dmarc_reports" {
  email = format("dmarc@%s", googleworkspace_domain.main.domain_name)
  name  = "DMARC Reports"
}

resource "googleworkspace_group_settings" "dmarc_reports" {
  email                          = googleworkspace_group.dmarc_reports.email
  allow_external_members         = true
  include_in_global_address_list = false
  who_can_discover_group         = "ALL_MEMBERS_CAN_DISCOVER"
}

resource "googleworkspace_group_members" "dmarc_reports" {
  group_id = googleworkspace_group.dmarc_reports.id

  dynamic "members" {
    for_each = var.gsuite_group_members.dmarc_reports

    content {
      role  = members.value
      email = googleworkspace_user.main[members.key].primary_email
    }
  }
}

resource "googleworkspace_group" "shopping_list" {
  email = format("shopping-list@%s", googleworkspace_domain.main.domain_name)
  name  = "OurGroceries"
}

resource "googleworkspace_group_members" "shopping_list" {
  group_id = googleworkspace_group.shopping_list.id

  dynamic "members" {
    for_each = var.gsuite_group_members.shopping_list

    content {
      role  = members.value
      email = googleworkspace_user.main[members.key].primary_email
    }
  }
}

resource "googleworkspace_group" "sysadmin" {
  email = format("sysadmin@%s", googleworkspace_domain.main.domain_name)
  name  = "System Administrators"
}

resource "googleworkspace_group_members" "sysadmin" {
  group_id = googleworkspace_group.sysadmin.id

  dynamic "members" {
    for_each = var.gsuite_group_members.sysadmin

    content {
      role  = members.value
      email = googleworkspace_user.main[members.key].primary_email
    }
  }
}
