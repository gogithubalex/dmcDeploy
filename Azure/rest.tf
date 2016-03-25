resource "azure_instance" "rest" {
    name = "${var.stack_prefix}${var.rest_name}"
    image = "OpenLogic 7.2"
    size = "Basic_A2"
    storage_service_name = "${var.storage_service_name}"
    location = "${var.location}"
    username = "${var.azure_username}"
    ssh_key_thumbprint = "${var.ssh_key_thumbprint}"
    hosted_service_name = "${var.rest_name}"
    endpoint {
        name = "SSH"
        protocol = "tcp"
        public_port = 22
        private_port = 22
    }

    endpoint {
        name = "WEB"
        protocol = "tcp"
        public_port = 8080
        private_port = 8080
    }

    endpoint {
        name = "solr"
        protocol = "tcp"
        public_port = 8009
        private_port = 8009
    }

    connection {
        user = "${var.azure_username}"
        type = "ssh"
        key_file = "${var.pvt_key}"

        agent = false
    }

    provisioner "file" {
        source = "../scripts/createAmiBase/buildMachineImage_rest.sh"
        destination = "/tmp/RestBaseScript.sh"
    }



    provisioner "file" {
        source = "../scripts/deployMe_rest.sh"
        destination = "/tmp/script.sh"
    }

    provisioner "remote-exec" {
            inline = [
            "echo 'export dump_location2=${var.cloudChoice}' >> /tmp/profile",
            "sudo bash -c 'cat /tmp/profile >> /etc/profile' ",
            "source /etc/profile" ,
            "chmod +x /tmp/script.sh",
            "cd /tmp",
            "bash -x RestBaseScript.sh 2>&1 | tee out.log",
            "bash -x script.sh 2>&1 | tee out.log"
            ]


    }

}
