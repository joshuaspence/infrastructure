variable "home_assistant_config" {
  type = object({
    host    = string
    version = string
  })
}

resource "helm_release" "home_assistant" {
  name  = "home-assistant"
  chart = "stable/home-assistant"

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
    value = format("{%s}", var.home_assistant_config.host)
  }
}
