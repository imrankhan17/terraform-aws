provider "aws" {
  region = var.region
}

resource "aws_security_group" "ssh_web" {
  name = "tf_sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "key" {
  key_name   = "tf_key"
  public_key = file(var.public_key)
}

data "aws_ami" "ubuntu" {
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

resource "aws_instance" "web" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.key.key_name
  security_groups = [aws_security_group.ssh_web.name]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = self.public_ip
    private_key = file(var.private_key)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install nginx -y",
      "sudo bash -c 'echo Welcome to ${var.domain} > /var/www/html/index.html'"
    ]
  }
}

resource "aws_route53_zone" "primary" {
  name = var.domain
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "www.${aws_route53_zone.primary.name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.web.public_ip]
}

resource "aws_route53_record" "blank" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = aws_route53_zone.primary.name
  type    = "A"
  ttl     = 300
  records = [aws_instance.web.public_ip]
}
