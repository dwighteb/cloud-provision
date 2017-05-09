provider "google" {
  project     = "mystical-sweep-166814"
  region      = "us-east1"
}

terraform {
  backend "gcs" {
    bucket  = "tf-state-dwight"
    path    = "mystical-sweep/address/terraform.tfstate"
    project = "mystical-sweep-166814"
  }
}

resource "google_compute_address" "vpn-ipaddress" {
  name = "vpn-ipaddress"
}
