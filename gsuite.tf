resource "googleworkspace_domain" "primary" {
  domain_name = local.primary_domain
}

resource "googleworkspace_domain" "secondary" {
  domain_name = each.value
  for_each    = toset(local.secondary_domains)
}

resource "googleworkspace_domain_alias" "main" {
  parent_domain_name = googleworkspace_domain.primary.domain_name
  domain_alias_name  = each.key
  for_each           = { for domain in local.alias_domains : domain => var.domains[domain] }
}

variable "gsuite_users" {
  type = map(object({
    family_name = string
    given_name  = string
    is_admin    = bool
    aliases     = set(string)
  }))
}

resource "googleworkspace_user" "main" {
  name {
    family_name = each.value.family_name
    given_name  = each.value.given_name
  }

  primary_email = format("%s@%s", each.key, googleworkspace_domain.primary.domain_name)
  aliases       = [for alias in each.value.aliases : format(alias, each.key)]
  is_admin      = each.value.is_admin
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
    sysadmin      = map(string)
  })
}

resource "googleworkspace_group" "dmarc_reports" {
  email = format("dmarc@%s", googleworkspace_domain.primary.domain_name)
  name  = "DMARC Reports"
}

resource "googleworkspace_group_settings" "dmarc_reports" {
  email                          = googleworkspace_group.dmarc_reports.email
  allow_external_members         = true
  include_in_global_address_list = false
  who_can_discover_group         = "ALL_MEMBERS_CAN_DISCOVER"

  lifecycle {
    ignore_changes = [
      # See hashicorp/terraform-provider-googleworkspace#398.
      is_archived,
    ]
  }
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
  email = format("shopping-list@%s", googleworkspace_domain.primary.domain_name)
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
  email = format("sysadmin@%s", googleworkspace_domain.primary.domain_name)
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
