provider "google" {
  project     = "my-test-project-166915"
  region      = "us-east1"
}

terraform {
  backend "gcs" {
    bucket  = "tf-state-dwight"
    path    = "my-test-project/address/terraform.tfstate"
    project = "mystical-sweep-166814"
  }
}

resource "google_compute_address" "busyboxtest" {
  name = "busyboxtest"
}

output "ipaddress" {
  value = "${google_compute_address.busyboxtest.address}"
}
