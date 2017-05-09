provider "google" {
  project     = "mystical-sweep-166814"
  region      = "us-east1"
}

terraform {
  backend "gcs" {
    bucket  = "tf-state-dwight"
    path    = "mystical-sweep/compute/terraform.tfstate"
    project = "mystical-sweep-166814"
  }
}

variable "ip_address" {
  description = "The IP Address created for the vpn"
  default     = "35.185.10.131"
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
      nat_ip = "${var.ip_address}"
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
