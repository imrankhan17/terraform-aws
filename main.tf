provider "aws" {
  region = "eu-west-2"
}

resource "aws_key_pair" "tf_key" {
  key_name = "tf_key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "ssh_web" {
  name = "tf_sg"

  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami = "ami-0be057a22c63962cb"
  instance_type = "t2.micro"
  key_name = aws_key_pair.tf_key.key_name
  security_groups = [aws_security_group.ssh_web.name]

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install nginx -y"
    ]

    connection {
      type = "ssh"
      user = "ubuntu"
      host = aws_instance.web.public_ip
      private_key = file("~/.ssh/my_key.pem")
    }
  }

  tags = {
    Name = "web"
  }
}
