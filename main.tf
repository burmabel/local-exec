provider "aws" {
  region = "us-east-1"
}

resource "tls_private_key" "tls_connector" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "terraform_ec2_key" {
  key_name   = "terraform_ec2_key"
  public_key = tls_private_key.tls_connector.public_key_openssh

  tags = {
    Owner = "aika"
  }
}

resource "local_file" "terraform_ec2_key_file" {
  content  = tls_private_key.tls_connector.private_key_pem
  filename = "terraform_ec2_key.pem"

  provisioner "local-exec" {
    command = "chmod 400 terraform_ec2_key.pem"
  }
}

resource "aws_instance" "frontend" {
  ami                         = "ami-00c39f71452c08778"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.terraform_ec2_key.id
  subnet_id                   = "subnet-05fda0bc2541914c0"
  associate_public_ip_address = true
  security_groups             = ["sg-05787d23afd641fb6"]


  tags = {
    Name  = "frontend"
    Owner = "aika"
  }
}

output "public_ip" {
  value = aws_instance.frontend.public_ip
}