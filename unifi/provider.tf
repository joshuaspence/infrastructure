terraform {
  required_providers {
    unifi = {
      source  = "paultyng/unifi"
      version = ">= 0.28.0"
    }
  }

  experiments = [
    module_variable_optional_attrs,
  ]
}

