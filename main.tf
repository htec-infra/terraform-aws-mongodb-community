locals {
  instance_name        = var.name
  mongodb_password_src = "/${var.namespace}/mongodb/dba/password"

  volume_name      = "${var.name}-volume"
  host_mount_point = "/mongodb-data"
}

resource "aws_ssm_parameter" "mongo_dba_password" {
  name  = local.mongodb_password_src
  type  = "SecureString"
  value = random_password.mongo_dba.result
}

resource "random_password" "mongo_dba" {
  length = 32
}

resource "aws_ecs_cluster" "mongodb" {
  name = var.name
  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(var.tags, {
    Environment = var.environment
    Namespace   = var.namespace
  })

}

resource "aws_ecs_task_definition" "mongodb_primary" {
  container_definitions    = data.template_file.mongodb_primary.rendered
  family                   = var.name
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  execution_role_arn       = aws_iam_role.ecs_tasks_execution_role.arn

  volume {
    name      = local.volume_name
    host_path = local.host_mount_point
  }

  tags = var.tags
}

resource "aws_ecs_service" "mongodb_primary" {
  name                               = "${var.name}-primary"
  cluster                            = aws_ecs_cluster.mongodb.arn
  task_definition                    = aws_ecs_task_definition.mongodb_primary.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100
  launch_type                        = "EC2"
}

data "template_file" "mongodb_primary" {
  template = file("${path.module}/modules/mongodb-node/templates/taskdef-mongo.tpl")

  vars = {
    mongodb_password_src     = local.mongodb_password_src
    mongodb_version          = var.mongodb_version
    mongodb_container_cpu    = var.mongodb_container_cpu
    mongodb_container_memory = var.mongodb_container_memory
    volume_name              = local.volume_name
  }

  depends_on = [aws_ssm_parameter.mongo_dba_password]
}

module "primary_node" {
  source = "./modules/mongodb-node"

  namespace   = var.namespace
  env_code    = var.env_code
  environment = var.environment

  name                 = var.name
  subnet_id            = var.subnet_id
  instance_profile_arn = aws_iam_instance_profile.ecs_instance_profile.arn
  instance_type        = var.instance_type
}

// TODO: Add logs for ECS tasks

// TODO: Security Group ruls
