terraform {
  required_providers {
    unifi = {
      source  = "paultyng/unifi"
      version = ">= 0.29.0"
    }
  }

  experiments = [
    module_variable_optional_attrs,
  ]
}

