resource "aws_security_group" "webserver-traffic" {
    
  name        = "${var.project}-${var.environment}-frontend"
  description = "Allow http & https traffic"
 

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
    
  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

    
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
      
    "Name" = "${var.project}-${var.environment}-frontend"
    "Project" = var.project
    "Env" = var.environment
      
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "remote-traffic" {
    
  name        = "${var.project}-${var.environment}-remote"
  description = "Allow ssh traffic"
 


  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

    
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
      
    "Name" = "${var.project}-${var.environment}-remote"
    "Project" = var.project

  }

  lifecycle {
    create_before_destroy = true
  }
  
}

resource "aws_security_group" "db-traffic" {

  name        = "${var.project}-${var.environment}-db-traffic"
  description = "Allow ssh traffic"



  ingress {
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {

    "Name" = "${var.project}-${var.environment}-db-traffic"
    "Project" = var.project
    "Env" = var.environment

  }

  lifecycle {
    create_before_destroy = true
  }

}



resource "aws_instance"  "Webserver" {
    
  ami = var.instance_ami
  instance_type = var.instance_type
  key_name = var.key_name 
  vpc_security_group_ids  = [ aws_security_group.webserver-traffic.id , aws_security_group.remote-traffic.id ]
  tags = {
    "Name" = "${var.project}-${var.environment}-webserver"
    "Project" = var.project
    "Env" = var.environment
  }

  user_data = file("userdata.sh")

}


resource "aws_instance"  "db-server" {

  ami = var.instance_ami
  instance_type = var.instance_type
  key_name = var.key_name
  vpc_security_group_ids  = [ aws_security_group.webserver-traffic.id , aws_security_group.db-traffic.id ]
  tags = {
    "Name" = "${var.project}-${var.environment}-db-server"
    "Project" = var.project
    "Env" = var.environment
  }

  user_data = file("userdata.sh")

}


resource "aws_eip" "webserver" {
  instance = aws_instance.Webserver.id
  vpc      = true
  tags = {
    "Project" = var.project
    "Env" = var.environment
  }


}

resource "aws_route53_record" "blog" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "blog.getabhiram.tech"
  type    = "A"
  ttl     = 500
  records = [ aws_eip.webserver.public_ip ]
}
