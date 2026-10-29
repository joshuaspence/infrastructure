variable "github_actions_organization_secrets" {
  description = "Values of the `spence-com-au` organization's Actions secrets, keyed by secret name."
  type        = map(string)

  validation {
    condition     = alltrue([for value in values(var.github_actions_organization_secrets) : value != ""])
    error_message = "An empty value would overwrite the secret on GitHub."
  }
}

variable "github_actions_repository_secrets" {
  description = "Values of Actions secrets in `spence-com-au` repositories, keyed by repository name and then secret name."
  type        = map(map(string))

  validation {
    condition     = alltrue(flatten([for secrets in values(var.github_actions_repository_secrets) : [for value in values(secrets) : value != ""]]))
    error_message = "An empty value would overwrite the secret on GitHub."
  }
}

resource "github_organization_settings" "main" {
  provider = github.organization

  name          = "spence.com.au"
  billing_email = googleworkspace_user.main["josh"].primary_email
  location      = "Australia"

  has_organization_projects                = false
  has_repository_projects                  = false
  members_can_create_internal_repositories = false
}

data "github_repository" "organization_meta" {
  provider  = github.organization
  full_name = "spence-com-au/.github"
}

data "github_app" "pogo_utils_bot" {
  provider = github.organization
  slug     = "pogo-utils-bot"
}

resource "github_organization_ruleset" "block_force_pushes" {
  provider    = github.organization
  name        = "Block force pushes"
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }

    repository_name {
      include = ["~ALL"]
      exclude = []
    }
  }

  rules {
    non_fast_forward = true
  }
}

resource "github_organization_ruleset" "common_workflows" {
  provider    = github.organization
  name        = "Common workflows"
  target      = "branch"
  enforcement = "active"

  # Repository role 5 is the built-in admin role.
  bypass_actors {
    actor_id    = 5
    actor_type  = "RepositoryRole"
    bypass_mode = "pull_request"
  }

  bypass_actors {
    actor_id    = data.github_app.pogo_utils_bot.id
    actor_type  = "Integration"
    bypass_mode = "always"
  }

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }

    repository_name {
      include = ["~ALL"]
      exclude = []
    }
  }

  rules {
    required_workflows {
      do_not_enforce_on_create = true

      dynamic "required_workflow" {
        for_each = ["actionlint", "claude-review", "dependabot"]

        content {
          repository_id = data.github_repository.organization_meta.repo_id
          path          = ".github/workflows/${required_workflow.value}.yaml"
          ref           = "refs/heads/${data.github_repository.organization_meta.default_branch}"
        }
      }
    }
  }
}

resource "github_organization_ruleset" "require_linear_history" {
  provider    = github.organization
  name        = "Require linear history"
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }

    repository_name {
      include = ["~ALL"]
      exclude = []
    }
  }

  rules {
    required_linear_history = true
  }
}

resource "github_organization_ruleset" "require_pull_request" {
  provider    = github.organization
  name        = "Require pull request"
  target      = "branch"
  enforcement = "active"

  # Repository role 5 is the built-in admin role.
  bypass_actors {
    actor_id    = 5
    actor_type  = "RepositoryRole"
    bypass_mode = "pull_request"
  }

  bypass_actors {
    actor_id    = data.github_app.pogo_utils_bot.id
    actor_type  = "Integration"
    bypass_mode = "always"
  }

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }

    repository_name {
      include = ["~ALL"]
      exclude = []
    }
  }

  rules {
    pull_request {
      required_approving_review_count = 1
      dismiss_stale_reviews_on_push   = true
      allowed_merge_methods           = ["squash"]
    }
  }
}

resource "github_organization_ruleset" "restrict_deletions" {
  provider    = github.organization
  name        = "Restrict deletions"
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }

    repository_name {
      include = ["~ALL"]
      exclude = []
    }
  }

  rules {
    deletion = true
  }
}

resource "github_actions_organization_secret" "secret" {
  provider    = github.organization
  secret_name = each.key
  visibility  = "all"
  value       = each.value

  for_each = var.github_actions_organization_secrets
}

locals {
  # Keyed `<repository>:<secret>`, which is also the provider's import ID.
  github_actions_repository_secrets = merge([
    for repository, secrets in var.github_actions_repository_secrets : {
      for name, value in secrets : "${repository}:${name}" => {
        repository = repository
        name       = name
        value      = value
      }
    }
  ]...)
}

resource "github_actions_secret" "secret" {
  provider    = github.spence_com_au
  repository  = each.value.repository
  secret_name = each.value.name
  value       = each.value.value

  for_each = local.github_actions_repository_secrets
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

