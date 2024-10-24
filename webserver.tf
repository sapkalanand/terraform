resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a" # Adjust as needed
  map_public_ip_on_launch = true
}


resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

resource "aws_security_group" "web" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

resource "aws_instance" "ubuntu_web" {
  ami             = "ami-0866a3c8686eaeeba" # Update with the latest Ubuntu AMI for your region
  instance_type   = "t2.micro"              # Free tier eligible
  subnet_id       = aws_subnet.main.id
  security_groups = [aws_security_group.web.id]

  tags = {
    Name = "UbuntuWebServer"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update
              sudo apt install -y apache2
              sudo systemctl start apache2
              sudo systemctl enable apache2
              sudo echo "<html><h1><b> Hi Jayant I LOVE YOU </b></h1> </html>" > /var/www/html/index.html
              sudo systemctl restart apache2
              EOF
}

output "instance_ip" {
  value = aws_instance.ubuntu_web.public_ip
}