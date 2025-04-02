# Networking module to create VPC, Subnet, and other networking resources
module "networking" {
  source              = "./modules/networking"
  vpc_cidr           = var.vpc_cidr
  vpc_name           = var.vpc_name 
  availability_zone  = var.availability_zone
  cidr_public_subnet = var.cidr_public_subnet
}

# Security Group module to define firewall rules for the EC2 instance
module "security_group" {
  source      = "./modules/security-groups"
  ec2_sg_name = "SG for EC2 to enable SSH(22), HTTPS(443) and HTTP(80)"
  vpc_id      = module.networking.dev_app_vpc_id
}

# EC2 instance resource to deploy API and Web application
resource "aws_instance" "api-web-vm" {
  ami                    = var.ami_id  
  instance_type          = var.instance_type  
  subnet_id              = module.networking.dev_app_public_subnet  
  vpc_security_group_ids = [module.security_group.dev_app_sg_id]  
  
  # User data script to configure the instance on launch
  user_data = templatefile("Script_path", {})
  
  tags = {
    Name = "api-web-vm"  # Tag for identifying the instance
  }
}
