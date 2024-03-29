data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"] # AWS
}
data "aws_vpc" "default" {
  default = true
}
resource "aws_instance" "web" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.web.id]

  tags = {
    Name = "HelloWorld-aml23"
  }
}

resource "aws_ec2_instance_state" "web" {
  instance_id   = aws_instance.web.id
  state         = "running"
}

resource "aws_security_group" "web" {
  name        = "webSG"
  description =  "Allow http/s in. Allow everything out"

  vpc_id      = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "web_http_in" {
  type          = "ingress"
  from_port     = 80
  to_port       = 80
  protocol      = "tcp"
  cidr_blocks   = ["0.0.0.0/0"]

  security_group_id = aws_security_group.web.id
}

resource "aws_security_group_rule" "web_https_in" {
  type          = "ingress"
  from_port     = 443
  to_port       = 443
  protocol      = "tcp"
  cidr_blocks   = ["0.0.0.0/0"]

  security_group_id = aws_security_group.web.id
}

resource "aws_security_group_rule" "ssh_in" {
  type          = "ingress"
  description   = "Allow ssh from anywhere"
  from_port     = 22
  to_port       = 22
  protocol      = tcp
  cidr_blocks   = ["0.0.0.0/0"]

  security_group_id = aws_security_group.web.id
}

resource "aws_security_group_rule" "web_all_out" {
  type          = "egress"
  from_port     = 0
  to_port       = 0
  protocol      = -1
  cidr_blocks   = ["0.0.0.0/0"]

  security_group_id = aws_security_group.web.id
}