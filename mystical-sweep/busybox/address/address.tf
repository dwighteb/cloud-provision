provider "google" {
  project     = "mystical-sweep-166814"
  region      = "us-east4"
}

terraform {
  backend "gcs" {
    bucket  = "tf-state-dwight"
    path    = "mystical-sweep/busybox/address/terraform.tfstate"
    project = "mystical-sweep-166814"
  }
}

resource "google_compute_address" "busyboxtest" {
  name = "busyboxtest"
}

output "ipaddress" {
  value = "${google_compute_address.busyboxtest.address}"
}
