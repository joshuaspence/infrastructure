variable "unifi_config" {
  type = object({
    host     = string
    timezone = string
    version  = string
  })
}

# TODO: Use external MongoDB.
resource "helm_release" "unifi" {
  name  = "unifi"
  chart = "stable/unifi"

  set {
    name  = "image.tag"
    value = var.unifi_config.version
  }

  set {
    name  = "ingress.enabled"
    value = true
  }

  set {
    name  = format("ingress.annotations.%s", replace("nginx.ingress.kubernetes.io/backend-protocol", ".", "\\."))
    value = "HTTPS"
  }

  set {
    name  = "ingress.hosts"
    value = format("{%s}", var.unifi_config.host)
  }

  set {
    name  = "timezone"
    value = var.unifi_config.timezone
  }
}
