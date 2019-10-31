/**
 * TODO: Add ingress controller or load balancer.
 * TODO: Add Kubernetes dashboard.
 */

# TODO: Should this be installed into its own namespace?
resource "helm_release" "home_assistant" {
  name  = "home-assistant"
  chart = "stable/home-assistant"

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

  set {
    name  = "image.tag"
    value = "0.101.0"
  }
}
