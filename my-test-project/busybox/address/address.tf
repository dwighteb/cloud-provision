provider "google" {
  project     = "my-test-project-166915"
  region      = "us-east4"
}

terraform {
  backend "gcs" {
    bucket  = "tf-state-dwighteb"
    path    = "my-test-project/busybox/address/terraform.tfstate"
    project = "my-test-project-166915"
  }
}

resource "google_compute_address" "busyboxtest" {
  name = "busyboxtest"
}

output "ipaddress" {
  value = "${google_compute_address.busyboxtest.address}"
}
