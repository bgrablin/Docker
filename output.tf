output "ip" {
  value = "${aws_eip.eip_one.public_ip}"
}