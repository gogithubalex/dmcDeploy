
variable "azure_settings_file" {
    default = "azure_creds.publishsettings"
}

variable "ssh_key_thumbprint" {
	default = ""
}

variable "pvt_key" {

}

variable "hosted_service" {
	description = "Which hosted service would you like to launch your VM in?"
	default = ""
}

variable "storage_service_name" {
	description = "Which storeage would you like to store your VM in?"
	default = ""
}

variable "azure_username" {}

variable "location" {}
variable "solr_name" {}


variable "db_name" {}

variable "rest_name" {}

variable "front_name" {}

variable "cloudChoice" {}
