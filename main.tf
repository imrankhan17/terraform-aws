provider "aws" {
  region = "eu-west-2"
}

resource "aws_security_group" "ssh_web" {
  name = "tf_sg"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ubuntu" {
  owners = ["099720109477"]
  most_recent = true
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

resource "aws_instance" "web" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name = "my_key"
  security_groups = [aws_security_group.ssh_web.name]

  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ubuntu"
      host = aws_instance.web.public_ip
      private_key = file("~/.ssh/my_key.pem")
    }

    inline = [
      "sudo apt update -y",
      "sudo apt install nginx -y"
    ]
  }

  tags = {
    Name = "web"
  }
}

output "ip" {
  value = aws_instance.web.public_dns
}
