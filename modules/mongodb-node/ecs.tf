locals {
  volume_name      = "mongodb-volume"
  host_mount_point = "/mongodb-data"

  loggroup_path = "/ecs/${var.ecs_cluster_name}/${var.name}"

  hostname_ssm_path = "/${var.ecs_cluster_name}/${var.name}/hostname"

  node_envs = {
    standalone = [],
    primary = [{
      name : "MONGODB_REPLICA_SET_MODE",
      value : "primary"
      }, {
      name : "MONGODB_REPLICA_SET_KEY",
      value : var.mongodb_replica_set_key
    }],
    secondary = [{
      name : "MONGODB_REPLICA_SET_MODE",
      value : "secondary"
      }, {
      name : "MONGODB_REPLICA_SET_KEY",
      value : var.mongodb_replica_set_key
    }]
  }

  node_secrets = {
    standalone = [],
    primary = [{
      name : "MONGODB_ROOT_PASSWORD",
      valueFrom : "/${var.ecs_cluster_name}/dba/password"
      }, {
      name : "MONGODB_ADVERTISED_HOSTNAME",
      valueFrom : local.hostname_ssm_path
    }],
    secondary = [{
      name : "MONGODB_ADVERTISED_HOSTNAME",
      valueFrom : local.hostname_ssm_path
      }, {
      name : "MONGODB_INITIAL_PRIMARY_HOST",
      valueFrom : "/${var.ecs_cluster_name}/${var.primary_node_name}/hostname"
      }, {
      name : "MONGODB_INITIAL_PRIMARY_ROOT_PASSWORD",
      valueFrom : "/${var.ecs_cluster_name}/dba/password"
    }]
  }
}

data "aws_ecs_cluster" "this" {
  cluster_name = var.ecs_cluster_name
}

data "aws_region" "this" {}

########
# Primary node hostname
########

resource "aws_ssm_parameter" "mongodb_node_hostname" {
  name  = local.hostname_ssm_path
  type  = "String"
  value = join(".", compact([var.name, var.private_root_domain]))

  lifecycle {
    ignore_changes = [value]
  }
}

resource "aws_cloudwatch_log_group" "mongodb_node" {
  name = local.loggroup_path

  tags = merge(var.tags, {})

}

resource "aws_ecs_task_definition" "mongodb_node" {
  container_definitions = data.template_file.mongodb_primary.rendered
  family                = lower(join("-", [var.ecs_cluster_name, var.name]))

  network_mode = "awsvpc"

  requires_compatibilities = ["EC2"]
  task_role_arn            = var.ecs_execution_role_arn
  execution_role_arn       = var.ecs_execution_role_arn

  volume {
    name      = local.volume_name
    host_path = local.host_mount_point
  }

  tags = merge(var.tags, {})
}


resource "aws_ecs_service" "mongodb_node" {
  name                               = var.name
  cluster                            = data.aws_ecs_cluster.this.arn
  task_definition                    = aws_ecs_task_definition.mongodb_node.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 0
  deployment_maximum_percent         = 100
  launch_type                        = "EC2"

  network_configuration {
    assign_public_ip = false
    subnets          = [var.subnet_id]
    security_groups  = var.additional_security_group_ids
  }

  dynamic "service_registries" {
    for_each = var.service_discovery_namespace_id != null ? [aws_service_discovery_service.mongodb_node[0]] : []

    # Setting port is not supported whne using "host" or "bridge" network mode.
    content {
      registry_arn = service_registries.value.arn
    }
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

}

data "template_file" "mongodb_primary" {
  template = file("${path.module}/templates/taskdef-mongo.tpl")

  vars = {
    mongodb_version          = var.mongodb_version
    mongodb_container_cpu    = var.mongodb_container_cpu
    mongodb_container_memory = var.mongodb_container_memory
    volume_name              = local.volume_name
    loggroup_path            = local.loggroup_path
    app_region               = data.aws_region.this.name

    envs    = jsonencode(local.node_envs[var.mongodb_node_type])
    secrets = jsonencode(local.node_secrets[var.mongodb_node_type])
  }
}

/**
 * Create a new Service Discovery Service.
 */
resource "aws_service_discovery_service" "mongodb_node" {
  count = var.service_discovery_namespace_id != null ? 1 : 0
  name  = var.name

  dns_config {
    namespace_id = var.service_discovery_namespace_id

    dns_records {
      ttl  = var.service_discovery_dns_ttl
      type = var.service_discovery_dns_record_type
    }

    routing_policy = var.service_discovery_routing_policy
  }

  health_check_custom_config {
    failure_threshold = var.service_discovery_failure_threshold
  }
}
