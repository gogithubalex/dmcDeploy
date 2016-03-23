provider "azure" {
      publish_settings = "${file("${var.azure_settings_file}")}"
}

resource "azure_instance" "basic-server" {
    name = "${var.solr_name}"
    image = "OpenLogic 7.2"
    size = "Basic_A2"
    storage_service_name = "${var.storage_service_name}"
    location = "${var.location}"
    username = "${var.azure_username}"
    ssh_key_thumbprint = "${var.ssh_key_thumbprint}"
    hosted_service_name = "${var.solr_name}"
    endpoint {
        name = "SSH"
        protocol = "tcp"
        public_port = 22
        private_port = 22
    }

    endpoint {
        name = "WEB"
        protocol = "tcp"
        public_port = 80
        private_port = 80
    }

    connection {
        user = "${var.azure_username}"
        type = "ssh"
        key_file = "${var.pvt_key}"
        timeout = "2m"
        agent = false
    }

    provisioner "file" {
        source = "../scripts/createAmiBase/buildMachineImage_solr.sh"
        destination = "/tmp/BaseScript.sh"
    }

    provisioner "file" {
        source = "buildMachineImage_solr.sh"
        destination = "/tmp/script.sh"
    }

    provisioner "remote-exec" {
            inline = [
            "chmod +x /tmp/script.sh",
            "cd /tmp",
            "bash -x BaseScript.sh.sh 2>&1 | tee out.log",
            "bash -x script.sh 2>&1 | tee out.log"
            ]


    }

}
