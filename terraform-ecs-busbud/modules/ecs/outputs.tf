output "alb_dns_name" {
  value = aws_alb.application_load_balancer.dns_name
  description = "The DNS name of the Application Load Balancer"
}
