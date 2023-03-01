terraform {
  required_providers {
    aws={
      source = "hashicorp/aws"
      version = "4.46.0"
    }
  }
}
variable"vpc_id" {}

data"aws_vpc""selected" {
  id=var.vpc_id
  filter {
    name   ="tag:Name"
    values=["apache-vpc"]
  }
}
variable"subnet1_id" {}
data"aws_subnet""subnet1" {
  id= var.subnet1_id
  filter {
    name   ="tag:Name"
    values=["pub-sub"]
  }
}
variable"subnet2_id" {}
data"aws_subnet""subnet2" {
  id= var.subnet2_id
  filter {
    name   ="tag:Name"
    values=["pri-sub"]
  }
}

resource "aws_security_group" "sg"{
   name  = "Dynamic-SG"
   vpc_id       = data. aws_vpc.selected.id
   description = "aws_security group Dynamic Blocks"
   dynamic "ingress" {
     for_each = ["80", "22", "443"]
     content {
       description = "Allow port"
       from_port = ingress.value
       to_port = ingress.value
       protocol = "tcp"
       cidr_blocks = ["0.0.0.0/0"]
    }
  } 

   egress {
    description = "Allow ALL ports"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "sg"
  }
}
data "template_file" "user-data" {
  template = file("${path.module}/user-data")
}

## Create instance
resource "aws_instance" "web" {   
  ami             = "ami-0b5eea76982371e91" 
  instance_type   = var.instance_type
  key_name        = var.instance_key
  user_data       = data.template_file.user-data.rendered
  subnet_id       = data.aws_subnet.subnet1.id
  security_groups = [aws_security_group.sg.id]

  tags = {
    Name = "web"
  }
}
