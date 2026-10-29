variable "github_repositories" {
  type = map(object({
    description = string
    visibility  = optional(string)
    topics      = optional(list(string))

    deploy_keys = optional(map(object({
      key       = string
      read_only = optional(bool, false)
    })), {})

    actions_secrets = optional(map(string), {})
  }))
}

resource "github_repository" "repository" {
  name        = each.key
  description = each.value.description
  visibility  = each.value.visibility

  has_issues             = true
  delete_branch_on_merge = true
  archive_on_destroy     = true

  topics               = each.value.topics
  vulnerability_alerts = true

  lifecycle {
    ignore_changes = [
      # See integrations/terraform-provider-github#1419.
      security_and_analysis,
    ]
  }

  for_each = var.github_repositories
}

resource "github_repository_deploy_key" "deploy_key" {
  key        = each.value.key
  read_only  = each.value.read_only
  repository = each.value.repository
  title      = each.value.title

  # This is ugly, see hashicorp/terraform#22263.
  for_each = {
    for deploy_key in flatten([
      for repo_name, repo in var.github_repositories :
      [
        for key_name, key in repo.deploy_keys :
        {
          key = "${repo_name}-${key_name}",
          value = merge(key, {
            repository = github_repository.repository[repo_name].name,
            title      = title(replace(key_name, "_", " ")),
          })
        }
      ]
    ]) :
    deploy_key.key => deploy_key.value
  }
}

resource "github_actions_secret" "secret" {
  repository      = each.value.repository
  secret_name     = each.value.name
  plaintext_value = each.value.value

  # This is ugly, see hashicorp/terraform#22263.
  for_each = {
    for secret in flatten([
      for repo_name, repo in var.github_repositories :
      [
        for secret_name, secret_value in repo.actions_secrets :
        {
          key = "${repo_name}-${secret_name}"
          value = {
            repository = github_repository.repository[repo_name].name
            name       = upper(secret_name)
            value      = secret_value
          }
        }
      ]
    ]) :
    secret.key => secret.value
  }
}

resource "aws_route53_record" "github_pages_apex_ipv4" {
  zone_id = aws_route53_zone.main["spence.com.au"].zone_id
  name    = ""
  type    = "A"
  ttl     = 60 * 60

  records = [
    "185.199.108.153",
    "185.199.109.153",
    "185.199.110.153",
    "185.199.111.153",
  ]
}

resource "aws_route53_record" "github_pages_apex_ipv6" {
  zone_id = aws_route53_zone.main["spence.com.au"].zone_id
  name    = ""
  type    = "AAAA"
  ttl     = 60 * 60

  records = [
    "2606:50c0:8000::153",
    "2606:50c0:8001::153",
    "2606:50c0:8002::153",
    "2606:50c0:8003::153",
  ]
}

resource "aws_route53_record" "github_pages_www" {
  zone_id = aws_route53_zone.main["spence.com.au"].zone_id
  name    = "www"
  type    = "CNAME"
  ttl     = 60 * 60
  records = ["spence-com-au.github.io"]
}
