# This module is used to create eks cluster
# EKS Cluster Resources


resource "aws_iam_role" "my-cluster" {
  name = "terraform-eks-my-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "my-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.my-cluster.name
}

resource "aws_iam_role_policy_attachment" "my-cluster-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.my-cluster.name
}

resource "aws_security_group" "my-cluster" {
  name        = "terraform-eks-my-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.demo.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-eks-my-cluster"
  }
}

resource "aws_security_group_rule" "my-cluster-ingress-workstation-https" {
  cidr_blocks       = [local.workstation-external-cidr]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.my-cluster.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_eks_cluster" "my" {
  name     = var.cluster-name
  role_arn = aws_iam_role.my-cluster.arn

  vpc_config {
    security_group_ids = [aws_security_group.my-cluster.id]
    subnet_ids         = aws_subnet.my[*].id
  }

  depends_on = [
    aws_iam_role_policy_attachment.my-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.my-cluster-AmazonEKSVPCResourceController,
  ]
}
