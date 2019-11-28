variable "openebs_config" {
  type = object({
    ndm_version = string
    version     = string
  })
}

# TODO: Possibly tweak the following settings: `apiserver.sparse.enabled`, `ndm.sparse.*`, `ndm.filters.*`, `ndm.probes.*`
resource "helm_release" "openebs" {
  name      = "openebs"
  chart     = "stable/openebs"
  namespace = "openebs"

  set {
    name  = "apiserver.imageTag"
    value = var.openebs_config.version
  }

  set {
    name  = "provisioner.imageTag"
    value = var.openebs_config.version
  }

  set {
    name  = "localprovisioner.imageTag"
    value = var.openebs_config.version
  }

  set {
    name  = "webhook.imageTag"
    value = var.openebs_config.version
  }

  set {
    name  = "snapshotOperator.provisioner.imageTag"
    value = var.openebs_config.version
  }

  set {
    name  = "snapshotOperator.controller.imageTag"
    value = var.openebs_config.version
  }

  set {
    name  = "ndm.imageTag"
    value = format("v%s", var.openebs_config.ndm_version)
  }

  set {
    name  = "ndmOperator.imageTag"
    value = format("v%s", var.openebs_config.ndm_version)
  }

  set {
    name  = "jiva.imageTag"
    value = var.openebs_config.version
  }

  set {
    name  = "cstor.pool.imageTag"
    value = var.openebs_config.version
  }

  set {
    name  = "cstor.poolMgmt.imageTag"
    value = var.openebs_config.version
  }

  set {
    name  = "cstor.target.imageTag"
    value = var.openebs_config.version
  }

  set {
    name  = "cstor.volumeMgmt.imageTag"
    value = var.openebs_config.version
  }

  set {
    name  = "policies.monitoring.imageTag"
    value = var.openebs_config.version
  }
}
