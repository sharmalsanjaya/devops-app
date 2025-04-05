output "vpc_id" {
  value = aws_default_vpc.default_vpc.id
}

output "subnet_ids" {
  value = [
    aws_default_subnet.default_subnet_a.id,
    aws_default_subnet.default_subnet_b.id
  ]
}