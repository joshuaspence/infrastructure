variable "github_repositories" {
  type = map(object({
    description = string
    visibility  = optional(string)
    topics      = optional(list(string))

    deploy_keys = optional(map(object({
      key       = string
      read_only = optional(bool)
    })))

    actions_secrets = optional(map(string))
  }))
}

locals {
  github_repositories = defaults(var.github_repositories, {
    deploy_keys = {
      read_only = false
    }
  })
}

resource "github_repository" "repository" {
  name        = each.key
  description = each.value.description
  visibility  = each.value.visibility

  has_issues             = true
  delete_branch_on_merge = true
  archive_on_destroy     = true
  topics                 = each.value.topics
  vulnerability_alerts   = true

  for_each = local.github_repositories

  lifecycle {
    ignore_changes = [
      # Workaround for integrations/terraform-provider-github#1037.
      branches,
    ]
  }
}

resource "github_repository_deploy_key" "deploy_key" {
  key        = each.value.key
  read_only  = each.value.read_only
  repository = each.value.repository
  title      = each.value.title

  # This is ugly, see hashicorp/terraform#22263.
  for_each = {
    for deploy_key in flatten([
      for repo_name, repo in local.github_repositories :
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
      for repo_name, repo in local.github_repositories :
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

resource "github_actions_secret" "dockerhub_username" {
  repository      = github_repository.repository["uxg-boot"].name
  secret_name     = "DOCKER_USERNAME"
  plaintext_value = var.dockerhub_username
}

resource "github_actions_secret" "dockerhub_password" {
  repository      = github_repository.repository["uxg-boot"].name
  secret_name     = "DOCKER_PASSWORD"
  plaintext_value = dockerhub_token.github_actions.token
}

resource "dockerhub_token" "github_actions" {
  label  = "GitHub Actions"
  scopes = ["repo:write"]
}
