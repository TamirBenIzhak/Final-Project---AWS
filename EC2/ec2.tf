provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "jenkins" {
  ami                    = "ami-047ec28bc6067ac67"
  instance_type           = "t2.micro"
  key_name                = "First-Instance"
  vpc_security_group_ids  = ["sg-0b55c48dc2d2be1b9"]
  associate_public_ip_address = false  # Don't assign public IP, we will use EIP

  iam_instance_profile    = "Jenkins-Instance-Role"

  tags = {
    Name = "Jenkins"
  }

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }
}


data "aws_eip" "existing_jenkins_eip" {
  filter {
    name   = "allocation-id"
    values = ["eipalloc-0f0ec1eca06786b5c"]  # ✅ Available EIP
  }
}

# Associate the Elastic IP with the Jenkins instance
resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.jenkins.id
  allocation_id = data.aws_eip.existing_jenkins_eip.id
}
