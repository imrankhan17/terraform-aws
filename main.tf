provider "aws" {
  region = "eu-west-2"
}

resource "aws_instance" "example" {
  ami = "ami-0be057a22c63962cb"
  instance_type = "t2.micro"
  key_name = "my_key"
  security_groups = ["sg-05d52b79fd1eb0e1b"]
}
