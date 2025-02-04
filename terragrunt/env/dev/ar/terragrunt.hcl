include "backend" {
  path = find_in_parent_folders("_global/backend.hcl")
}

include "common" {
  path = find_in_parent_folders("_global/common.hcl")
}

terraform {
  source = "git::https://github.com/tu-repo/terraform-modules.git//main?ref=v1.0.0"
}

inputs = {
  country = "ar"
  product = "onboarding"
}