# TODO: Should this be installed into its own namespace?
resource "helm_release" "home_assistant" {
  name  = "home-assistant"
  chart = "stable/home-assistant"

  # image.repository
  # image.tag
  # service.type
  # service.port
  # service.annotations
  # service.clusterIP
  # service.externalIPs
  # service.loadBalancerIP
  # service.loadBalancerSourceRanges
  # hostNetwork
  # service.nodePort
  # ingress.enabled
  # ingress.annotations
  # ingress.path
  # ingress.hosts
  # ingress.tls
  # persistence.enabled
  # persistence.size
  # persistence.existingClaim
  # persistence.hostPath
  # persistence.storageClass
  # persistence.accessMode
  # configurator.enabled
  # configurator.image.repository
  # configurator.image.tag
  # configurator.hassApiUrl
  # configurator.hassApiPassword
  # configurator.basepath
  # configurator.ingress.enabled
  # configurator.ingress.annotations
  # configurator.ingress.hosts
  # configurator.ingress.tls
  # configurator.service.type
  # configurator.service.port
  # configurator.service.annotations
  # configurator.service.labels
  # configurator.service.clusterIP
  # configurator.service.externalIPs
  # configurator.service.loadBalancerIP
  # configurator.service.loadBalancerSourceRanges	
}
