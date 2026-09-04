# -----------------------------
# VPC
# -----------------------------
resource "aws_vpc" "cyberrange" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# -----------------------------
# Internet Gateway
# -----------------------------
resource "aws_internet_gateway" "cyberrange" {
  vpc_id = aws_vpc.cyberrange.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# -----------------------------
# Public Lab Subnet
# -----------------------------
resource "aws_subnet" "public_lab" {
  vpc_id                  = aws_vpc.cyberrange.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-lab"
  }
}

# -----------------------------
# Public Route Table
# -----------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.cyberrange.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cyberrange.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# -----------------------------
# Route Table Association
# -----------------------------
resource "aws_route_table_association" "public_lab" {
  subnet_id      = aws_subnet.public_lab.id
  route_table_id = aws_route_table.public.id
}

# -----------------------------
# CyberRange Target Security Group
# -----------------------------
resource "aws_security_group" "target" {
  name        = "${var.project_name}-target-sg"
  description = "Security group for CyberRange target instance"
  vpc_id      = aws_vpc.cyberrange.id

  # SSH - temporary access for administration
  ingress {
    description = "SSH administration"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  # HTTP - target web service
  ingress {
    description = "HTTP target service"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound traffic
  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-target-sg"
  }
}
# -----------------------------
# CyberRange Target EC2
# -----------------------------
resource "aws_instance" "target" {
  ami           = "ami-0f918f7e67a3323f0"
  instance_type = var.instance_type

  subnet_id = aws_subnet.public_lab.id

  vpc_security_group_ids = [
    aws_security_group.target.id
  ]

  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ssm.name

  user_data = <<-EOF
            #!/bin/bash

            apt-get update -y
            apt-get install -y nginx wget

            systemctl enable nginx
            systemctl start nginx

            echo "<h1>AWS CyberRange Target</h1>" > /var/www/html/index.html
            echo "<p>Authorized security testing environment.</p>" >> /var/www/html/index.html

            # Install CloudWatch Agent
            wget https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb

            dpkg -i amazon-cloudwatch-agent.deb

            # Create CloudWatch Agent configuration
            cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<'CONFIG'
            {
              "logs": {
                "logs_collected": {
                  "files": {
                    "collect_list": [
                      {
                        "file_path": "/var/log/auth.log",
                        "log_group_name": "/aws/cyberrange/${var.project_name}",
                        "log_stream_name": "{instance_id}/auth"
                      },
                      {
                        "file_path": "/var/log/nginx/access.log",
                        "log_group_name": "/aws/cyberrange/${var.project_name}",
                        "log_stream_name": "{instance_id}/nginx-access"
                      },
                      {
                        "file_path": "/var/log/nginx/error.log",
                        "log_group_name": "/aws/cyberrange/${var.project_name}",
                        "log_stream_name": "{instance_id}/nginx-error"
                      }
                    ]
                  }
                }
              }
            }
            CONFIG

            # Start CloudWatch Agent
            systemctl enable amazon-cloudwatch-agent
            systemctl restart amazon-cloudwatch-agent
            EOF

  tags = {
    Name = "${var.project_name}-target"
    Role = "CyberRange-Target"
  }
}

# -----------------------------
# IAM Role for CyberRange Target
# -----------------------------
resource "aws_iam_role" "target" {
  name = "${var.project_name}-target-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

# -----------------------------
# CloudWatch Agent Permissions
# -----------------------------
resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.target.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# -----------------------------
# EC2 Instance Profile
# -----------------------------
resource "aws_iam_instance_profile" "target" {
  name = "${var.project_name}-target-profile"
  role = aws_iam_role.target.name
}

# -----------------------------
# CyberRange CloudWatch Log Group
# -----------------------------
resource "aws_cloudwatch_log_group" "cyberrange" {
  name              = "/aws/cyberrange/${var.project_name}"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-logs"
  }
}

# -----------------------------
# IAM Role for VPC Flow Logs
# -----------------------------
resource "aws_iam_role" "flow_logs" {
  name = "${var.project_name}-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

# -----------------------------
# Flow Logs Policy
# -----------------------------
resource "aws_iam_role_policy" "flow_logs" {
  name = "${var.project_name}-flow-logs-policy"
  role = aws_iam_role.flow_logs.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]

        Resource = "*"
      }
    ]
  })
}

# -----------------------------
# VPC Flow Log Group
# -----------------------------
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/cyberrange/${var.project_name}/vpc-flow-logs"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-vpc-flow-logs"
  }
}

# -----------------------------
# VPC Flow Logs
# -----------------------------
resource "aws_flow_log" "cyberrange" {
  vpc_id = aws_vpc.cyberrange.id

  traffic_type = "ALL"

  iam_role_arn    = aws_iam_role.flow_logs.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn

  tags = {
    Name = "${var.project_name}-flow-logs"
  }
}

# -----------------------------
# SSM Access Role
# -----------------------------
resource "aws_iam_role" "ssm" {
  name = "${var.project_name}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

# -----------------------------
# SSM Managed Policy
# -----------------------------
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# -----------------------------
# SSM Instance Profile
# -----------------------------
resource "aws_iam_instance_profile" "ssm" {
  name = "${var.project_name}-ssm-profile"
  role = aws_iam_role.ssm.name
}

# -----------------------------
# CloudWatch permissions for SSM role
# -----------------------------
resource "aws_iam_role_policy_attachment" "ssm_cloudwatch" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}