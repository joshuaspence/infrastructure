provider "helm" {
  host            = module.eks.cluster_endpoint
  namespace       = kubernetes_service_account.tiller.metadata[0].namespace
  install_tiller  = true
  service_account = kubernetes_service_account.tiller.metadata[0].name
  #automount_service_account_token

  kubernetes {
    host                   = module.eks.cluster_endpoint
    token                  = data.aws_eks_cluster_auth.main.token 
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data) 
    load_config_file       = false
  }
}
