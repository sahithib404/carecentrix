resource "aws_security_group" "app_instance_sg" {
    name = "vpc_db"
    description = "Allow incoming database connections."

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        security_groups = ["${aws_security_group.web.id}"]
    }
    ingress { # MySQL
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = ["${aws_security_group.web.id}"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }

    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.centrix_vpc.id}"

    tags = {
        Name = "App server"
    }
}

resource "aws_instance" "app_instance" {
    ami = "${lookup(var.amis, var.region)}"
    availability_zone = "us-east-1a"
    instance_type = "t2.micro"
    key_name = "${var.aws_key_name}"
    vpc_security_group_ids = ["${aws_security_group.app_instance_sg.id}"]
    subnet_id = "${aws_subnet.us-east-1a-private.id}"
    source_dest_check = false
    iam_instance_profile = "centrix_app_role"

    user_data = <<EOF
		             #! /bin/bash
                sudo amazon-linux-extras install nginx1 -y
		            sudo service nginx start
                EOF


    tags = {
        Name = "App server"
    }
}
