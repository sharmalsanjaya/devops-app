variable "ec2_sg_name" {}
variable "vpc_id" {}

output "dev_app_sg_id" {
  value = aws_security_group.devops-app-ec2_sg.id
}

resource "aws_security_group" "devops-app-ec2_sg" {
  name        = var.ec2_sg_name
  description = "Allow 22(SSH), 80(http) inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow remote SSH from anywhere"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  # enable http
  ingress {
    description = "Allow HTTP request from anywhere"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  # enable https
  ingress {
    description = "Allow HTTPS request from anywhere"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }

  #Outgoing request
  egress {
    description = "Allow outgoing request"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Security Groups to allow SSH(22), HTTP(80) and HTTPS(443)"
  }
}


