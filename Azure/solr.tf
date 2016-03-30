
resource "azure_instance" "solr" {
    name = "${var.stack_prefix}${var.solr_name}"
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

    endpoint {
        name = "solr"
        protocol = "tcp"
        public_port = 8983
        private_port = 8983
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
        source = "../scripts/createAmiBase/buildMachineImage_solr.sh"
        destination = "/tmp/SolrBaseScript.sh"
    }

    provisioner "file" {
        source = "../scripts/deployMe_solr.sh"
        destination = "/tmp/script.sh"
    }

    provisioner "remote-exec" {
            inline = [
            "chmod +x /tmp/script.sh",
            "cd /tmp",
            "bash -x RestBaseScript.sh.sh 2>&1 | tee out.log",
            "bash -x SolrBaseScript.sh.sh 2>&1 | tee out.log",
            "bash -x script.sh 2>&1 | tee out.log"
            ]


    }

}