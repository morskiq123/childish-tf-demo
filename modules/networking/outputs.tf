output "id_vpc" {
  value = aws_vpc.app_vpc.id
}

output "id_subnets"{
  value = aws_subnet.public_subnets.*.id
}
