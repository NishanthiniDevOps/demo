provider "aws" {
  region = "us-east-1"
  profile = "default"
}

resource "aws_security_group" "alb" {
  name        = "tf_alb_security_group_an"
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

resource "aws_security_group" "web" {
  name        = "tf_ec2_web_an"
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

resource "aws_security_group" "db" {
  name        = "tf_rds_an"
  vpc_id      = "vpc-09c076a7f444fddb8"

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups =  [aws_security_group.web.id]
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

resource "aws_db_subnet_group" "sg" {
  name       = "tf-task-subnetgroup-an"
  subnet_ids = ["subnet-09f52595d38046ee7", "subnet-0a93fc1355de0d0bb"]
}

resource "aws_db_instance" "db1" {
  allocated_storage    = 20
  identifier           = "demo-an"
  engine               = "postgres"
  engine_version       = "13.9"
  instance_class       = "db.t3.micro"
  username             = var.db_username
  password             = var.db_pass
  skip_final_snapshot  = true
  db_subnet_group_name =  aws_db_subnet_group.sg.name
  vpc_security_group_ids = [aws_security_group.db.id]
}


resource "aws_instance" "nginx1" {
  ami = "ami-0fec2c2e2017f4e7b"
  instance_type = "t2.small"
  key_name = "nisha" 
  vpc_security_group_ids = [aws_security_group.web.id]
  subnet_id = "subnet-09f52595d38046ee7"
  }  

resource "aws_alb" "front_end" {
  name = "tf-task-alb-an"
  security_groups = ["${aws_security_group.alb.id}"]
  subnets = ["subnet-09f52595d38046ee7", "subnet-0a93fc1355de0d0bb"]     
}

resource "aws_lb_target_group" "front_end" {
 name     = "tf-task-alb-target-an"
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
  target_id        = aws_instance.nginx1.id
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