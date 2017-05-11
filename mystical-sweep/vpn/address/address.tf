provider "google" {
  project     = "mystical-sweep-166814"
  region      = "us-east1"
}

terraform {
  backend "gcs" {
    bucket  = "tf-state-dwight"
    path    = "mystical-sweep/vpn/address/terraform.tfstate"
    project = "mystical-sweep-166814"
  }
}

resource "google_compute_address" "vpn-ipaddress" {
  name = "vpn-ipaddress"
}

output "ipaddress" {
  value = "${google_compute_address.vpn-ipaddress.address}"
}
