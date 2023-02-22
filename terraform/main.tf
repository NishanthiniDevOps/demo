provider "aws" {
  region = "us-east-1"
  profile = "default"
}

resource "aws_security_group" "alb" {
  name        = "tf_alb_security_group"
  vpc_id      = "vpc-09c076a7f444fddb8"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_alb" "front_end" {
  name = "tf-task-alb"
  security_groups = ["${aws_security_group.alb.id}"]
  subnets = ["subnet-09f52595d38046ee7", "subnet-0a93fc1355de0d0bb"]     
}

resource "aws_lb_target_group" "front_end" {
 name     = "tf-task-alb-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "vpc-09c076a7f444fddb8"
  health_check {
    path = "/"
    port = 80
  }
}

resource "aws_lb_target_group_attachment" "test" {
  target_group_arn = aws_lb_target_group.front_end.arn
  target_id        = aws_instance.nginx.id
  port             = 80
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = "${aws_alb.front_end.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_end.arn
  }
}

resource "aws_db_subnet_group" "sg" {
  name       = "tf-task-subnetgroup"
  subnet_ids = ["subnet-09f52595d38046ee7", "subnet-0a93fc1355de0d0bb"]
}

resource "aws_db_instance" "db" {
  allocated_storage    = 20
  identifier           = "demo"
  engine               = "postgres"
  engine_version       = "13.9"
  instance_class       = "db.t3.micro"
  username             = var.db_username
  password             = var.db_pass
  skip_final_snapshot  = true
  db_subnet_group_name =  aws_db_subnet_group.sg.name
  vpc_security_group_ids = ["sg-03f3bec675823a5e0"]
}

data "template_file" "script" {
  template = "${file("script.sh")}"

  vars = {
    db_username = "${var.db_username}"
    db_pass = "${var.db_pass}"
    db = "${var.db}"
    host = "demo.cyz5xzfnvpjf.us-east-1.rds.amazonaws.com "
  }
}

data "template_cloudinit_config" "config" {
  gzip          = false
  base64_encode = false

  # Main cloud-config configuration file.
  part {
    content_type = "text/x-shellscript"
    content      = "${data.template_file.script.rendered}"
  }
}

resource "aws_instance" "nginx" {
  ami = "ami-0fec2c2e2017f4e7b"
  instance_type = "t2.small"
  key_name = "nisha" 
  vpc_security_group_ids = ["sg-03f3bec675823a5e0"]
  subnet_id = "subnet-09f52595d38046ee7"
  user_data =  "${data.template_cloudinit_config.config.rendered}"
  }   
