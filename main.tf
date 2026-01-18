# This code is compatible with Terraform 4.25.0 and versions that are backward compatible to 4.25.0.
# For information about validating this Terraform code, see https://developer.hashicorp.com/terraform/tutorials/gcp-get-started/google-cloud-platform-build#format-and-validate-the-configuration
variable "zone" {
  default = "us-east1"
}

provider "google" {
  project = "gcp1-484519"   
  region  = "us-east1"
  zone    = "us-east1-b"    
}
resource "google_compute_instance" "iac-project-cicd-server2" {
  boot_disk {
    auto_delete = true
    device_name = "iac-project-cicd-server2"
    

    initialize_params {
      image = "projects/debian-cloud/global/images/debian-12-bookworm-v20240415"
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
  name         = "iac-project-cicd-server2"

  network_interface {
    access_config {
      network_tier = "standard"
    }

    queue_count = 0
    stack_type  = "IPV4_ONLY"
    subnetwork  = "default"

    #subnetwork  = "projects/gcp-cicd/regions/us-east1/subnetworks/default"
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

  tags = ["http-server", "https-server"]
  zone = "us-east1-b"
}

