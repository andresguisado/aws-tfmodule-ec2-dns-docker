# AWS IAM role

resource "aws_iam_role" "demo-conjur" {
  name = "${var.client_name}-${var.product}-${var.environment}-${var.region}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "demo-conjur-AmazonEC2FullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  role       = aws_iam_role.demo-conjur.name 
}

# AWS Security Group
resource "aws_security_group" "demo-conjur" {
  name        = "${var.client_name}-${var.product}-${var.environment}-${var.region}-sc"
  description = "demo-conjur security group"
  vpc_id      = aws_vpc.demo-conjur.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.client_name}-${var.product}-${var.environment}-${var.region}-sc"
  }
}

# AWS Security Group Rules
resource "aws_security_group_rule" "demo-conjur-ingress-workstation-ssh" {
  cidr_blocks       = ["${local.workstation-external-cidr}"]
  description       = "Allow workstation to communicate with the EC2 instance by SSH"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.demo-conjur.id
  to_port           = 22
  type              = "ingress"
}

resource "aws_security_group_rule" "demo-conjur-ingress-workstation-https" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow workstation to communicate with the EC2 instance by HTTPS"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.demo-conjur.id
  to_port           = 443
  type              = "ingress"
}
resource "aws_security_group_rule" "demo-conjur-ingress-workstation-ldaps" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow workstation to communicate with the EC2 instance by ldaps"
  from_port         = 636
  protocol          = "tcp"
  security_group_id = aws_security_group.demo-conjur.id
  to_port           = 636
  type              = "ingress"
}
resource "aws_security_group_rule" "demo-conjur-ingress-workstation-postgresendpoint" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow workstation to communicate with the EC2 instance by postgres endpoint"
  from_port         = 5432
  protocol          = "tcp"
  security_group_id = aws_security_group.demo-conjur.id
  to_port           = 5432
  type              = "ingress"
}
resource "aws_security_group_rule" "demo-conjur-ingress-workstation-postgresreplication" {
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow workstation to communicate with the EC2 instance by postgres replication"
  from_port         = 1999
  protocol          = "tcp"
  security_group_id = aws_security_group.demo-conjur.id
  to_port           = 1999
  type              = "ingress"
}

# AWS AMI
data "aws_ami" "demo-conjur" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${var.aws_ami}"]
  }

  owners = ["${var.owner_ami}"]
}

resource "aws_iam_instance_profile" "demo-conjur" {
  name = "${var.client_name}-${var.product}-${var.environment}-${var.region}"
  role = aws_iam_role.demo-conjur.name
}

# AWS EIP
resource "aws_eip" "demo-conjur" {
  vpc                         = "true"
}

resource "aws_eip_association" "demo-conjur" {
  instance_id                 = aws_instance.demo-conjur.id
  allocation_id               = aws_eip.demo-conjur.id
}

# AWS ROUTE 53
data "aws_route53_zone" demo-conjur {
  name = var.r53_zoneid_public
}

resource "aws_route53_record" "demo-conjur" {
  zone_id                     = data.aws_route53_zone.demo-conjur.id
  name                        = "${var.dns_public_name}.${data.aws_route53_zone.demo-conjur.name}"
  type                        = "A"
  ttl                         = 1
  records                     = ["${aws_eip.demo-conjur.public_ip}"]
}

# AWS EC2
resource "aws_instance" "demo-conjur" {

  ami                         = data.aws_ami.demo-conjur.id
  instance_type               = var.instance_type
  iam_instance_profile        = aws_iam_instance_profile.demo-conjur.name
  subnet_id                   = aws_subnet.demo-conjur.id
  vpc_security_group_ids      = [aws_security_group.demo-conjur.id]
  key_name                 = var.ssh_key_name
  #user_data_base64            = "${base64encode(local.demo-node-userdata)}"

  tags = {
    Name = "${var.client_name}-${var.product}-${var.environment}-${var.region}"
  }
}

# AWS EC2 provisioner
resource "null_resource" "example_provisioner" {

    provisioner "file" {
      source      = "provisioner_scripts/${var.ssh_script}"
      destination = "/tmp/script.sh"
    }

    provisioner "remote-exec" {
      inline = [
        "chmod +x /tmp/script.sh",
        "sh /tmp/script.sh",
      ]    
    }

    connection {
      type     = "ssh"  
      user     = var.ssh_user
      host     = aws_eip.demo-conjur.public_ip
      private_key = file("~/.ssh/id_rsa")
    }
    depends_on = [aws_eip.demo-conjur]
  }