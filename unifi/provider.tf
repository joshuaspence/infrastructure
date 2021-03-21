terraform {
  required_providers {
    unifi = {
      source  = "paultyng/unifi"
      version = ">= 0.24.0"
    }
  }

  experiments = [
    module_variable_optional_attrs,
    provider_sensitive_attrs,
  ]
}

