output "ip" {
  value = aws_instance.web.public_dns
  description = "The URL of the server instance."
}

output "nameservers" {
  value = aws_route53_zone.primary.name_servers
  description = "List of nameservers to be used by the domain name provider e.g. GoDaddy."
}
