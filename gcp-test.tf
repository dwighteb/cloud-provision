provider "google" {
  credentials = "${file("~/.gcloud/Terraform-test-project.json")}"
  project     = "my-test-project-166915"
  region      = "us-east1"
}

resource "google_compute_instance_template" "http8080" {
  name           = "http8080"
  machine_type   = "f1-micro"
  can_ip_forward = false

  tags = ["test-instance", "http8080"]

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
                            nohup busybox httpd -f -p 8080 &
                            EOF


  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}

resource "google_compute_target_pool" "http8080" {
  name = "http8080"
}

resource "google_compute_instance_group_manager" "http8080" {
  name = "http8080"
  zone = "us-east1-b"

  instance_template  = "${google_compute_instance_template.http8080.self_link}"
  target_pools       = ["${google_compute_target_pool.http8080.self_link}"]
  base_instance_name = "http8080"
}

resource "google_compute_autoscaler" "http8080" {
  name   = "http8080"
  zone   = "us-east1-b"
  target = "${google_compute_instance_group_manager.http8080.self_link}"

  autoscaling_policy = {
    max_replicas    = 5
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.5
    }
  }
}

resource "google_compute_forwarding_rule" "http8080" {
  name        = "vpn-forward"
  target      = "${google_compute_target_pool.http8080.self_link}"
  ip_protocol = "TCP"
  port_range  = "8080"
}

resource "google_compute_firewall" "http8080" {
  name    = "http-8080-allow"
  network = "default"
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
}
