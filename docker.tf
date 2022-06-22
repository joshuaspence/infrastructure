resource "dockerhub_repository" "uxg_setup" {
  name             = "uxg-setup"
  namespace        = var.dockerhub_username
  description      = ""
  full_description = ""
}
