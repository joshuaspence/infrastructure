terraform {
  required_providers {
    remote = {
      source = "tenstad/remote"
    }

    unifi = {
      source  = "paultyng/unifi"
      version = ">= 0.33.0"
    }
  }

  experiments = [
    module_variable_optional_attrs,
  ]
}

