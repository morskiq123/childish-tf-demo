# This security group is used for the public subnets.
# With the current configuration, it allows ALL traffic (both incoming and outgoing)
# from the ports specified in the variables.tf file within this module.

resource "aws_security_group" "app_sg" {
    name = "${var.app_name}_public_sg"
    description = "Allows HTTP/S from everywhere, SSH from our IP only"
    vpc_id = var.id_vpc

    dynamic "ingress" {
        for_each = var.allowed_ports_public
        content {
            from_port = ingress.value
            to_port = ingress.value
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }

    dynamic "egress" {
        for_each = var.allowed_ports_public
        content {
            from_port = egress.value
            to_port = egress.value
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }
}

