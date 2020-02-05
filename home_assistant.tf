variable "home_assistant_config" {
  type = object({
    host    = string
    version = string
  })
}

# TODO: Fix network discovery.
# TODO: Manage configuration using config maps.
resource "helm_release" "home_assistant" {
  name       = "home-assistant"
  chart      = "home-assistant"
  repository = data.helm_repository.stable.metadata[0].name

  set {
    name  = "image.tag"
    value = var.home_assistant_config.version
  }

  set {
    name  = "ingress.enabled"
    value = true
  }

  set {
    name  = "ingress.hosts"
    value = format("{%s}", join(",", [var.home_assistant_config.host]))
  }
}
