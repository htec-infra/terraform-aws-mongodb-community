locals {
  HandlerId = random_password.node_id.result

  mongodb_ebs_tags = merge(var.tags, {
    Name      = "MongoDB ${title(var.mongodb_node_type)} EBS"
    HandlerId = local.HandlerId
  })

  mongodb_node_tags = merge(var.tags, {
    Name      = "MongoDB ${title(var.mongodb_node_type)} Node"
    HandlerId = local.HandlerId
  })

  name_prefix     = join("-", [var.ecs_cluster_name, var.name, ""])
  ec2_ebs_device  = "/dev/xvdt"
  ebs_mount_point = "/mongodb-data"
}

data "aws_ami" "ecs" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

data "aws_subnet" "this" {
  id = var.subnet_id
}

resource "random_password" "node_id" {
  length  = 16
  special = false
}

data "template_cloudinit_config" "user_data" {
  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/templates/init.yaml", {
      cluster_name = var.ecs_cluster_name
    })
  }
  part {
    filename     = "attach-ebs.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/templates/attach-ebs.sh", {
      VOLUME_HANDLER_ID = local.HandlerId
      MOUNT_POINT       = local.ebs_mount_point
      DEVICE_ID         = local.ec2_ebs_device
    })
  }
  dynamic "part" {
    for_each = var.service_discovery_namespace_id == null ? [1] : []
    content {
      filename     = "update-params.sh"
      content_type = "text/x-shellscript"
      content = templatefile("${path.module}/templates/update-params.sh", {
        hostname_ssm_path = local.hostname_ssm_path
      })
    }

  }
}

resource "aws_launch_template" "mongodb" {
  name_prefix   = local.name_prefix
  image_id      = data.aws_ami.ecs.id
  instance_type = var.instance_type

  user_data = data.template_cloudinit_config.user_data.rendered

  iam_instance_profile {
    arn = var.instance_profile_arn
  }

  vpc_security_group_ids = var.additional_security_group_ids

  monitoring {
    enabled = true
  }

  placement {
    availability_zone = data.aws_subnet.this.availability_zone
  }

  tag_specifications {
    resource_type = "instance"
    tags          = local.mongodb_node_tags
  }
}

resource "aws_autoscaling_group" "mongodb" {
  name_prefix      = local.name_prefix
  desired_capacity = 1
  max_size         = 1
  min_size         = 1

  launch_template {
    id      = aws_launch_template.mongodb.id
    version = "$Latest"
  }

  vpc_zone_identifier = [var.subnet_id]
}

####
# Dedicated EBS
###

resource "aws_ebs_volume" "this" {
  count             = 1
  availability_zone = data.aws_subnet.this.availability_zone
  encrypted         = true
  size              = var.mongodb_storage_size
  type              = "gp3"

  tags = local.mongodb_ebs_tags

  lifecycle {
    prevent_destroy = false
  }
}
