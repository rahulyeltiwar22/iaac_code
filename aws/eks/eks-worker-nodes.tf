
# EKS Worker Nodes Resources


resource "aws_iam_role" "my-node" {
  name = "terraform-eks-my-node"

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

resource "aws_iam_role_policy_attachment" "my-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.my-node.name
}

resource "aws_iam_role_policy_attachment" "my-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.my-node.name
}

resource "aws_iam_role_policy_attachment" "my-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.my-node.name
}

resource "aws_eks_node_group" "my" {
  cluster_name    = aws_eks_cluster.my.name
  node_group_name = "my"
  node_role_arn   = aws_iam_role.my.node.arn
  subnet_ids      = aws_subnet.my[*].id

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.my-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.my-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.my-node-AmazonEC2ContainerRegistryReadOnly,
  ]
}
