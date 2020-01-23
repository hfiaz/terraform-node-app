provider "aws" {
  region = "eu-west-1"
}
resource "aws_instance" "app_instance" {
  ami = "${var.app_ami_id}"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids = ["${aws_security_group.app_security_group.id}"]
  subnet_id = "${aws_subnet.hussain_subnet.id}"
  user_data = "${data.template_file.app_init.rendered}"
  tags = {
    Name = "hussain-engineering47-terraform-app"
  }
}
resource "aws_instance" "mongo_instance" {
  ami = "${var.mongo_ami_id}"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids = ["${aws_security_group.mongo_security_group.id}"]
  subnet_id = "${aws_subnet.hussain_subnet.id}"
  user_data = "${data.template_file.app_init.rendered}"
  tags = {
    Name = "hussain-engineering47-terraform-mongo"
    }
}

resource "aws_security_group" "app_security_group" {
  name = "${var.name}security_group"
  vpc_id = "${var.vpc_id}"
  description = "allow inbound Traffic"
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
  tags = {
    Name = "hussain-eng47-terraform-app-security-group"
  }
}

resource "aws_security_group" "mongo_security_group" {
  name = "${var.name_db}security_group"
  vpc_id = "${var.vpc_id}"
  description = "allow inbound Traffic"
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
  tags = {
    Name = "hussain-eng47-terraform-mongo-security-group"
  }
}

resource "aws_subnet" "hussain_subnet" {
  vpc_id = "${var.vpc_id}"
  cidr_block = "10.0.120.0/24"
  tags = {
    Name = "hussain-eng47-app-public-subnet"
  }
}

resource "aws_route_table" "app_route_table" {
  vpc_id = "${var.vpc_id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${data.aws_internet_gateway.default.id}"
  }
  tags = {
    Name = "hussain-eng47-app-route-table"
  }
}

data "aws_internet_gateway" "default" {
  filter {
    name = "attachment.vpc-id"
    values = ["${var.vpc_id}"]
  }
}

data "template_file" "app_init" {
  template = "${file("./scripts/app/init.sh.tpl")}"
}
