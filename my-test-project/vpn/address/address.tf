provider "google" {
  project     = "my-test-project-166915"
  region      = "us-east1"
}

terraform {
  backend "gcs" {
    bucket  = "tf-state-dwighteb"
    path    = "my-test-project/vpn/address/terraform.tfstate"
    project = "my-test-project-166915"
  }
}

resource "google_compute_address" "vpn-ipaddress" {
  name = "vpn-ipaddress"
}

output "ipaddress" {
  value = "${google_compute_address.vpn-ipaddress.address}"
}
