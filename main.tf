output "instance_ip" {
  value = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}

resource "google_compute_instance" "vm_instance" {
  name         = "s7-test"
  machine_type = "g1-small"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network       = "${google_compute_network.default.name}"
    access_config {
    }
 }

  provisioner "remote-exec" {
    inline = [
        "sudo useradd ${var.user_name}",
        "sudo mkdir -p /home/${var.user_name}/.ssh",
        "sudo touch /home/${var.user_name}/.ssh/authorized_keys",
        "sudo echo '${var.user_pubkey}' > authorized_keys",
        "sudo mv authorized_keys /home/${var.user_name}/.ssh",
        "sudo chown -R ${var.user_name}:${var.user_name} /home/${var.user_name}/.ssh",
        "sudo chmod 700 /home/${var.user_name}/.ssh",
        "sudo chmod 600 /home/${var.user_name}/.ssh/authorized_keys",
   ]

    connection {
     type        = "ssh"
     host        = "${google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip}"
     user        = "${var.remote_user}"
     private_key = "${file("id_rsa")}"
    }

  }

  provisioner "local-exec" {
     command = "ansible-playbook -u ${var.remote_user} -b -i '${google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip},' --private-key ./id_rsa ./playbook.yml" 
  }
}

resource "google_compute_network" "default" {
  name                    = "test-network"
}

resource "google_compute_firewall" "default" {
  name    = "test-firewall"
  network = "${google_compute_network.default.name}"

  allow {
    protocol = "tcp"
    ports    = ["22", "8080"]
  }

}
