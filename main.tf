locals {
  instance_name = var.name

  resource_suffix = var.resource_name_with_env_suffix ? var.env_code : ""

  cluster_name = join("-", compact([
    lower(var.namespace), "mongodb", local.resource_suffix
  ]))

  mongodb_password_ssm_path = "/${local.cluster_name}/dba/password"

  filter_primary_node = compact([for node in var.mongodb_nodes : node.type == "primary" ? node.unique_name : ""])
  primary_node_name   = length(local.filter_primary_node) > 0 ? local.filter_primary_node[0] : "primary"

  tags = merge(var.tags, {
    Environment = var.environment
    CostCenter  = "Application"
    Tenancy     = "Shared"
  })
}

data "aws_subnet" "this" {
  id = var.mongodb_nodes.0.subnet_id
}

resource "aws_ecs_cluster" "mongodb" {
  name = local.cluster_name
  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(var.tags, {
    Environment = var.environment
    Namespace   = var.namespace
  })

}

########
# Primary node credentials
########

resource "random_password" "mongo_dba" {
  length  = 32
  special = false
}

resource "aws_ssm_parameter" "mongo_dba_password" {
  name  = local.mongodb_password_ssm_path
  type  = "SecureString"
  value = random_password.mongo_dba.result
}

########
# Security Groups
########

resource "aws_security_group" "mongodb" {
  name_prefix = aws_ecs_cluster.mongodb.name
  vpc_id      = data.aws_subnet.this.vpc_id

  egress {
    description = "Allow all egress traffic"
    from_port   = 53
    protocol    = "TCP"
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 27017
    protocol    = "TCP"
    to_port     = 65345
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    for_each = var.mongodb_node_ingress_cidr_block
    content {
      from_port   = 27017
      to_port     = 65345
      protocol    = "TCP"
      cidr_blocks = [ingress.value]
    }
  }

  dynamic "ingress" {
    for_each = var.mongodb_node_ingress_sgs
    content {
      from_port       = 27017
      to_port         = 27017
      protocol        = "TCP"
      security_groups = [ingress.value.id]
      description     = ingress.value.description
    }
  }
}



//noinspection HILUnresolvedReference
module "mongodb_nodes" {
  source = "./modules/mongodb-node"

  for_each = {
    for index, node in var.mongodb_nodes : node.unique_name => node
  }

  namespace   = var.namespace
  env_code    = var.env_code
  environment = var.environment

  disable_mongodb_service = var.disable_mongodb_service

  name                   = each.value.unique_name
  primary_node_name      = local.primary_node_name
  subnet_id              = each.value.subnet_id
  instance_type          = var.instance_type
  ecs_cluster_name       = aws_ecs_cluster.mongodb.name
  ecs_execution_role_arn = aws_iam_role.ecs_tasks_execution_role.arn
  instance_profile_arn   = aws_iam_instance_profile.ecs_instance_profile.arn
  additional_security_group_ids = [
    aws_security_group.mongodb.id
  ]
  mongodb_node_type    = each.value.type
  mongodb_storage_size = var.mongodb_storage_size
  mongodb_version      = var.mongodb_version

  mongodb_container_cpu    = var.mongodb_container_cpu
  mongodb_container_memory = var.mongodb_container_memory

  service_discovery_namespace_id = var.service_discovery_namespace_id
  private_root_domain            = var.private_root_domain

  tags = local.tags

  depends_on = [
    aws_ecs_cluster.mongodb
  ]
}

