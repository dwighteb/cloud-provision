provider "google" {
  project     = "my-test-project-166915"
  region      = "us-east1"
}

terraform {
  backend "gcs" {
    bucket  = "tf-state-dwighteb"
    path    = "my-test-project/vpn/compute/terraform.tfstate"
    project = "my-test-project-166915"
  }
}

data "terraform_remote_state" "address" {
  backend = "gcs"
  config {
    bucket  = "tf-state-dwighteb"
    path    = "my-test-project/vpn/address/terraform.tfstate"
    project = "my-test-project-166915"
  }
}

resource "google_compute_instance" "vpn-instance" {
  name  = "vpn1"
  machine_type = "f1-micro"
  zone = "us-east1-b"
  can_ip_forward = true

  tags = ["docker-cloud", "vpn"]

  disk {
    image = "ubuntu-os-cloud/ubuntu-1604-lts"
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = "${data.terraform_remote_state.address.ipaddress}"
    }
  }

  metadata_startup_script = "echo vpn > /test.txt"

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }

}

resource "google_compute_firewall" "vpn-access" {
  name    = "vpn-access"
  network = "default"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "udp"
    ports    = ["500", "4500"]
  }
}
