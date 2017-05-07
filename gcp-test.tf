provider "google" {
  credentials = "${file("~/.gcloud/Terraform-test-project.json")}"
  project     = "my-test-project-166915"
  region      = "us-east1"
}

resource "google_compute_instance" "test-instance" {
  name  = "test-instance1"
  machine_type = "f1-micro"
  zone = "us-east1-b"
  can_ip_forward = true

  tags = ["test-instance"]

  disk {
    image = "ubuntu-os-cloud/ubuntu-1604-lts"
  }

  network_interface {
    network = "default"

    access_config {
      // ephermeral IP
    }
  }

  metadata_startup_script = "echo hello > /test.txt"

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }

}
