variable "prometheus_config" {
  type = object({
    hosts = object({
      alertmanager = string
      prometheus   = string
    })

    versions = object({
      alertmanager  = string
      node_exporter = string
      prometheus    = string
    })
  })
}

resource "helm_release" "prometheus" {
  name  = "prometheus"
  chart = "stable/prometheus"

  set {
    name  = "alertmanager.image.tag"
    value = format("v%s", var.prometheus_config.versions.alertmanager)
  }

  set {
    name  = "alertmanager.baseURL"
    value = format("http://%s", var.prometheus_config.hosts.alertmanager)
  }

  set {
    name  = "alertmanager.ingress.enabled"
    value = true
  }

  set {
    name  = "alertmanager.ingress.hosts"
    value = format("{%s}", var.prometheus_config.hosts.alertmanager)
  }

  set {
    name  = "nodeExporter.image.tag"
    value = format("v%s", var.prometheus_config.versions.node_exporter)
  }

  set {
    name  = "server.image.tag"
    value = format("v%s", var.prometheus_config.versions.prometheus)
  }

  set {
    name  = "server.ingress.enabled"
    value = true
  }

  set {
    name  = "server.ingress.hosts"
    value = format("{%s}", var.prometheus_config.hosts.prometheus)
  }
}
