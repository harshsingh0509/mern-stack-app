provider "aws" {
  region = "us-east-1" # Change this to your preferred region
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a" # Change this to a preferred AZ
}

resource "aws_subnet" "subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b" # Change this to a different AZ
}

resource "aws_instance" "jump_server" {
  ami                         = "ami-04b4f1a9cf54c11d0" # Example AMI ID
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.subnet_1.id
  key_name                    = "mern-stack"
  associate_public_ip_address = true

  tags = {
    Name = "Jump Server"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y openjdk-11-jdk
              EOF
}

resource "aws_instance" "jenkins" {
  ami                         = "ami-014f7ab33242ea43c" # Replace with the valid AMI ID
  instance_type               = "t2.medium"
  subnet_id                   = aws_subnet.subnet_1.id
  key_name                    = "mern-stack"
  associate_public_ip_address = true

  tags = {
    Name = "Jenkins Server"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y openjdk-11-jdk
              wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
              sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
              sudo apt-get update
              sudo apt-get install -y jenkins
              sudo systemctl start jenkins
              sudo systemctl enable jenkins
              EOF
}

output "jump_server_public_ip" {
  value = aws_instance.jump_server.public_ip
}

output "jenkins_public_ip" {
  value = aws_instance.jenkins.public_ip
}
