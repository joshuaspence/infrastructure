variable "domain_registrant" {
  type = object({
    user           = string
    phone_number   = string
    address_line_1 = string
    city           = string
    state          = string
    zip_code       = string
    country_code   = string
  })
}

locals {
  domain_registrant_user = googleworkspace_user.main[var.domain_registrant.user]

  domain_registrant = {
    address_line_1 = var.domain_registrant.address_line_1
    city           = var.domain_registrant.city
    country_code   = var.domain_registrant.country_code
    email          = local.domain_registrant_user.primary_email
    first_name     = local.domain_registrant_user.name[0].given_name
    last_name      = local.domain_registrant_user.name[0].family_name
    phone_number   = var.domain_registrant.phone_number
    state          = var.domain_registrant.state
    zip_code       = var.domain_registrant.zip_code
  }
}

resource "aws_route53domains_registered_domain" "main" {
  admin_privacy      = true
  auto_renew         = true
  domain_name        = each.key
  registrant_privacy = true
  tech_privacy       = true
  transfer_lock      = length(regexall("\\.com\\.au$", each.key)) == 0 ? true : false

  admin_contact {
    address_line_1 = local.domain_registrant.address_line_1
    city           = local.domain_registrant.city
    country_code   = local.domain_registrant.country_code
    email          = local.domain_registrant.email
    first_name     = local.domain_registrant.first_name
    last_name      = local.domain_registrant.last_name
    phone_number   = local.domain_registrant.phone_number
    state          = local.domain_registrant.state
    zip_code       = local.domain_registrant.zip_code
  }

  registrant_contact {
    address_line_1 = local.domain_registrant.address_line_1
    city           = local.domain_registrant.city
    country_code   = local.domain_registrant.country_code
    email          = local.domain_registrant.email
    first_name     = local.domain_registrant.first_name
    last_name      = local.domain_registrant.last_name
    phone_number   = local.domain_registrant.phone_number
    state          = local.domain_registrant.state
    zip_code       = local.domain_registrant.zip_code
  }

  tech_contact {
    address_line_1 = local.domain_registrant.address_line_1
    city           = local.domain_registrant.city
    country_code   = local.domain_registrant.country_code
    email          = local.domain_registrant.email
    first_name     = local.domain_registrant.first_name
    last_name      = local.domain_registrant.last_name
    phone_number   = local.domain_registrant.phone_number
    state          = local.domain_registrant.state
    zip_code       = local.domain_registrant.zip_code
  }

  for_each = { for domain_name, domain in var.domains : domain_name => domain.domain_registration if domain.domain_registration.registrar == "aws" }
  provider = aws.us_east_1
}
