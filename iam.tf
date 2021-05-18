locals {
  iam_prefix = "${var.namespace}${title(var.env_code)}"
}

/**
 * Instance profile for instances launched by autoscaling
 */

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "${local.iam_prefix}MongoDbInstanceProfile"
  role = aws_iam_role.ecs_instance_role.name
}

resource "aws_iam_role" "ecs_instance_role" {
  name               = "${local.iam_prefix}MongoDbInstanceRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_instance_role.json
}

data "aws_iam_policy_document" "ecs_instance_role" {
  statement {
    sid    = "EC2AssumeRole"
    effect = "Allow"
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy_attach" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_ssm_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "mongodb_node" {
  name_prefix = "ExtraPermissions-"
  role        = aws_iam_role.ecs_instance_role.id
  policy      = data.aws_iam_policy_document.mongodb_node.json
}

data "aws_iam_policy_document" "mongodb_node" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:AttachVolume",
      "ec2:CreateSnapshot",
      "ec2:CreateTags",
      "ec2:DeleteSnapshot",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInstances",
      "ec2:DescribeVolumes",
      "ec2:DescribeVolumeAttribute",
      "ec2:DescribeVolumeStatus",
      "ec2:DescribeSnapshots",
      "ec2:CopySnapshot",
      "ec2:DescribeSnapshotAttribute",
      "ec2:DetachVolume",
      "ec2:ModifySnapshotAttribute",
      "ec2:ModifyVolumeAttribute",
      "ec2:DescribeTags"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ssm:PutParameter"
    ]
    resources = ["arn:aws:ssm:*:*:parameter/${local.cluster_name}/*"]
  }
}

########
# Task Execution Role
########

data "aws_iam_policy_document" "mongodb_tasks_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_tasks_execution_role" {
  name               = "${local.iam_prefix}MongoDbTasksExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.mongodb_tasks_execution_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_tasks_execution_role" {
  role       = aws_iam_role.ecs_tasks_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ecs_tasks_inline_role" {
  role   = aws_iam_role.ecs_tasks_execution_role.id
  policy = data.aws_iam_policy_document.mongodb_ecs_task_inline.json
}

data "aws_iam_policy_document" "mongodb_ecs_task_inline" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:DescribeParameters",
      "ssm:GetParameters",
      "ssm:PutParameter"
    ]
    resources = ["arn:aws:ssm:*:*:parameter/${local.cluster_name}/*"]
  }
}
