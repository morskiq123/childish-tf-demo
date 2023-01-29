variable "id_vpc" {}

variable "app_name" {}

variable "allowed_ports_public" {
    description = "List of all allowed ports"
    type = list(any)
    default = ["80", "443"]
}
