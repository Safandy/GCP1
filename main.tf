# This code is compatible with Terraform 4.25.0 and versions that are backward compatible to 4.25.0.
# For information about validating this Terraform code, see https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/google-cloud-platform-build#format-and-validate-the-configuration
#variable "zone" {
 # default = "us-east1"
#}

provider "google" {
  project = "gcp1-484519"   
  region  = "us-east1"
  zone    = "us-east1-b"    
}
resource "google_compute_instance" "cicd-vm" {
  boot_disk {
    auto_delete = true
    device_name = "cicd-vm"
    
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 10
      type  = "pd-standard"
    }

    mode = "READ_WRITE"
  }

  can_ip_forward      = true
  deletion_protection = false
  enable_display      = true

  labels = {
    goog-ec-src = "vm_add-tf"
  }

  machine_type = "e2-micro"
  name         = "cicd-vm"

  network_interface {
    network        = "default"
    queue_count = 0
    stack_type  = "IPV4_ONLY"
    subnetwork  = "default"
    access_config {
      network_tier = "standard"
    }

    }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    preemptible         = false
    provisioning_model  = "STANDARD"
  }

  service_account {
    email  = "gcp-cicd@gcp1-484519.iam.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false
    enable_vtpm                 = true
  }



 tags = ["nginx", "http-server", "jenkins", "sonarqube"]

  metadata_startup_script = <<-EOF
    #!/bin/bash
    set -e
   #install nginx

    apt-get update -y
    apt-get install -y nginx
    systemctl enable nginx
    systemctl start nginx

    # Install Java (required for Jenkins & SonarQube)
    apt-get install -y openjdk-17-jdk

    # Install Docker
    apt-get install -y docker.io
    systemctl enable docker
    systemctl start docker

    # Install Jenkins
    curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | tee \
      /usr/share/keyrings/jenkins-keyring.asc > /dev/null

    echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
      https://pkg.jenkins.io/debian-stable binary/ | tee \
      /etc/apt/sources.list.d/jenkins.list > /dev/null

    apt-get update -y
    apt-get install -y jenkins
    systemctl enable jenkins
    systemctl start jenkins

    # Run SonarQube with Docker
    docker run -d --name sonarqube \
      -p 9000:9000 \
      sonarqube:lts
    NGINX_CONF

  ln -sf /etc/nginx/sites-available/cicd /etc/nginx/sites-enabled/cicd
  rm -f /etc/nginx/sites-enabled/default

  systemctl reload nginx  
  EOF
}
resource "google_compute_firewall" "allow_ci_ports" {
  name    = "allow-ci-ports"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "8080", "9000"]
  }

  source_ranges = ["0.0.0.0/0"]
}



