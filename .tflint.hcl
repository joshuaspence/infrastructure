config {
  module = true
}

plugin "aws" {
  enabled = true
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
  version = "0.23.1"
}

plugin "google" {
  enabled = true
  source  = "github.com/terraform-linters/tflint-ruleset-google"
  version = "0.23.1"
}

plugin "terraform" {
  enabled = true
  source  = "github.com/terraform-linters/tflint-ruleset-terraform"
  version = "0.4.0"
}

rule "terraform_documented_outputs" {
  enabled = false
}

rule "terraform_documented_variables" {
  enabled = false
}

rule "terraform_required_providers" {
  enabled = false
}

rule "terraform_standard_module_structure" {
  enabled = false
}
