provider "aws" {
  access_key = ""
  secret_key = ""
  region     = "us-west-2"
}

resource "aws_eip" "ip" {
  instance = "${aws_instance.web.id}"
  provisioner "local-exec" {
    command = "echo ${aws_eip.ip.public_ip} > ./ip_address.txt"
  }
}

resource "aws_security_group" "web" {
    name = "web"
    description = "Web Security Group"
 
    ingress {
        from_port = 80
        to_port = 80
	protocol = "tcp"
	cidr_blocks = ["0.0.0.0/0"]
    }
 
    ingress {
        from_port = 22
        to_port = 22
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

resource "aws_instance" "web" {
  ami           = "ami-718c6909"
  instance_type = "t2.micro"
  key_name = "aws_key_home"
  security_groups = ["web"]
  connection {
    host = "${self.public_ip}"
    user = "ubuntu"
    private_key = "${file("aws_key_home.pem")}"
    agent = "false"
    type = "ssh"
    timeout = "30s"
  }
  
  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install apache2 -y",
      "sudo chmod 666 /var/www/html/index.html",
      "sudo cat /dev/null>/var/www/html/index.html",   
      "sudo  echo \"automation for people\">/var/www/html/index.html"
    ]
  }
}
