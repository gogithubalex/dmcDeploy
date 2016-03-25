provider "azure" {
      publish_settings = "${file("${var.azure_settings_file}")}"
}

resource "azure_hosted_service" "hostFront" {
    name = "${var.front_name}"
    location = "Central US"
    ephemeral_contents = false
    description = "Hosted service front."
    label = "tf-hs-front"
    default_certificate_thumbprint = "${var.ssh_key_thumbprint}"
}

resource "azure_hosted_service" "hostRest" {
    name = "${var.rest_name}"
    location = "Central US"
    ephemeral_contents = false
    description = "Hosted service rest."
    label = "tf-hs-rest"
    default_certificate_thumbprint = "${var.ssh_key_thumbprint}"
}

resource "azure_hosted_service" "hostDb" {
    name = "${var.db_name}"
    location = "Central US"
    ephemeral_contents = false
    description = "Hosted service db."
    label = "tf-hs-db"
    default_certificate_thumbprint = "${var.ssh_key_thumbprint}"
}

resource "azure_hosted_service" "hostSolr" {
    name = "${var.solr_name}"
    location = "Central US"
    ephemeral_contents = false
    description = "Hosted service solr."
    label = "tf-hs-solr"
    default_certificate_thumbprint = "${var.ssh_key_thumbprint}"
}
