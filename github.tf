variable "github_repositories" {
  type = map(object({
    description = string
    topics      = optional(list(string))

    deploy_keys = optional(map(object({
      key       = string
      read_only = optional(bool)
    })))
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

  has_issues             = true
  delete_branch_on_merge = true
  archive_on_destroy     = true
  topics                 = each.value.topics
  vulnerability_alerts   = true

  for_each = local.github_repositories
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
          key   = "${repo_name}-${key_name}",
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
