terraform {
  required_providers {
    unifi = {
      source  = "paultyng/unifi"
      version = ">= 0.27.0"
    }
  }

  experiments = [
    module_variable_optional_attrs,
  ]
}

