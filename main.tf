provider "aws" {
  region = "us-east-1" 
}

resource "aws_instance" "db" {
  ami           = "ami-0bb4c991fa89d4b9b"
  instance_type = "t2.micro"

  tags = {
    Name = "DB Server" 
  }
}

resource "aws_instance" "web" {
  ami           = "ami-0bb4c991fa89d4b9b"
  instance_type = "t2.micro"
  user_data = file("server-script.sh")
   tags = {
    Name = "Web Server"
  }
}

resource "aws_eip" "web_ip" {
  instance = aws_instance.web.id
}

variable "ingress" {
  type    = list(number)
  default = [80, 443]
}

variable "egress" {
  type    = list(number)
  default = [80, 443]
}

resource "aws_security_group" "web_traffic" {
  name = "AllowWebTraffic" 

  dynamic "ingress" {
    for_each = var.ingress
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp" 
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  dynamic "egress" {
    for_each = var.egress
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = "tcp" 
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

output "privateIP" {
  value = aws_instance.db.private_ip
}

output "publicIP" {
  value = aws_eip.web_ip.public_ip 
}
