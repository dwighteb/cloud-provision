provider "google" {
  project     = "mystical-sweep-166814"
  region      = "us-east4"
}

terraform {
  backend "gcs" {
    bucket  = "tf-state-dwight"
    path    = "mystical-sweep/busybox/compute/terraform.tfstate"
    project = "mystical-sweep-166814"
  }
}

data "terraform_remote_state" "address" {
  backend = "gcs"
  config {
    bucket  = "tf-state-dwight"
    path    = "mystical-sweep/busybox/address/terraform.tfstate"
    project = "mystical-sweep-166814"
  }
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default     = 8080
}

resource "google_compute_instance_template" "busyboxtest" {
  name           = "busyboxtest"
  machine_type   = "f1-micro"
  can_ip_forward = false

  tags = ["test-instance", "busyboxtest"]

  disk {
    source_image = "ubuntu-os-cloud/ubuntu-1604-lts"
  }

  network_interface {
    network = "default"

    access_config {
      // ephermeral IP
    }
  }

  metadata_startup_script = <<-EOF
                            #!/bin/bash
                            echo "Hello, World" > index.html
                            nohup busybox httpd -f -p "${var.server_port}" &
                            EOF


  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}

resource "google_compute_target_pool" "busyboxtest" {
  name = "busyboxtest"
  health_checks = [
      "${google_compute_http_health_check.busyboxtest.name}",
    ]
}

resource "google_compute_http_health_check" "busyboxtest" {
  name         = "busyboxtest"
  port         = "${var.server_port}"
  timeout_sec        = 1
  check_interval_sec = 5
}

resource "google_compute_instance_group_manager" "busyboxtest" {
  name = "busyboxtest"
  zone = "us-east4-b"

  instance_template  = "${google_compute_instance_template.busyboxtest.self_link}"
  target_pools       = ["${google_compute_target_pool.busyboxtest.self_link}"]
  base_instance_name = "busyboxtest"
}

resource "google_compute_autoscaler" "busyboxtest" {
  name   = "busyboxtest"
  zone   = "us-east4-b"
  target = "${google_compute_instance_group_manager.busyboxtest.self_link}"

  autoscaling_policy = {
    max_replicas    = 5
    min_replicas    = 1
    cooldown_period = 120

    cpu_utilization {
      target = 0.5
    }
  }
}

resource "google_compute_forwarding_rule" "busyboxtest" {
  name        = "busyboxtest"
  target      = "${google_compute_target_pool.busyboxtest.self_link}"
  ip_protocol = "TCP"
  port_range  = "${var.server_port}"
  ip_address  = "${data.terraform_remote_state.address.ipaddress}"
}

resource "google_compute_firewall" "busyboxtest" {
  name    = "busyboxtest"
  network = "default"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["${var.server_port}"]
  }
}
