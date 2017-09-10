provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "us-west-2"
}

resource "aws_eip" "ip1" {
  instance = "${aws_instance.web1.id}"
  provisioner "local-exec" {
    command = "echo web1 ${aws_eip.ip1.public_ip} > ./ip_address.txt"
  }
}

resource "aws_eip" "ip2" {
  instance = "${aws_instance.web2.id}"
  provisioner "local-exec" {
    command = "echo web2 ${aws_eip.ip2.public_ip} >> ./ip_address.txt"
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

resource "aws_instance" "web1" {
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

  resource "aws_instance" "web2" {
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
        "sudo  echo \"automation for people2\">/var/www/html/index.html"
      ]
    }
}

resource "aws_elb" "lb" {
  name               = "terraform-elb"
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]

  listener {
      instance_port     = 80
      instance_protocol = "http"
      lb_port           = 80
      lb_protocol       = "http"
    }

    health_check {
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout             = 3
      target              = "HTTP:80/"
      interval            = 30
    }

    instances                   = ["${aws_instance.web1.id}", "${aws_instance.web2.id}"]
      cross_zone_load_balancing   = true
      idle_timeout                = 400
      connection_draining         = true
      connection_draining_timeout = 400

  provisioner "local-exec" {
    command = "echo lb ${aws_elb.lb.dns_name} >> ./ip_address.txt"
  }
}
