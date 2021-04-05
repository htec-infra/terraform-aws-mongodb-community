# MongoDB Cluster on ECS

## Overview

Community MongoDB Cluster for 

## Usage

```hcl
module "mongodb_cluster" {
  source = ""
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_primary_node"></a> [primary\_node](#module\_primary\_node) | ./modules/mongodb-node |  |

## Resources

| Name | Type |
|------|------|
| [aws_ecs_cluster.mongodb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_service.mongodb_primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.mongodb_primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_iam_instance_profile.ecs_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.ecs_instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ecs_tasks_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ecs_tasks_inline_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.mongodb_node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ecs_instance_role_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_instance_ssm_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_tasks_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_ssm_parameter.mongo_dba_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [random_password.mongo_dba](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_iam_policy_document.ecs_instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.mongodb_ecs_task_inline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.mongodb_node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.mongodb_tasks_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [template_file.mongodb_primary](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env_code"></a> [env\_code](#input\_env\_code) | Short environment name tag (e.g. dev, stg, prod) | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment indicator where the MongoDB will be instantiated. E.g. Development, Staging, QA, Production | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Type of ECS container instance type | `string` | n/a | yes |
| <a name="input_mongodb_container_cpu"></a> [mongodb\_container\_cpu](#input\_mongodb\_container\_cpu) | CPU capacity required for mongo container ( 1024 == 1 cpu) | `number` | `1024` | no |
| <a name="input_mongodb_container_memory"></a> [mongodb\_container\_memory](#input\_mongodb\_container\_memory) | Memory required for mongo container | `number` | `1606` | no |
| <a name="input_mongodb_version"></a> [mongodb\_version](#input\_mongodb\_version) | Docker image version of mongo | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Base name for the cluster and other resources | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Project namespace | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region in which resources should be created | `string` | n/a | yes |
| <a name="input_security_group_id"></a> [security\_group\_id](#input\_security\_group\_id) | Security group id for container EC2 instance | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet id for container EC2 instance | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Default tags to be attached for every resource in the module | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->

## Development

### Prerequisites

- [terraform](https://learn.hashicorp.com/terraform/getting-started/install#installing-terraform)
- [terraform-docs](https://github.com/segmentio/terraform-docs)
- [pre-commit](https://pre-commit.com/#install)
- [golang](https://golang.org/doc/install#install)

### Configurations

- Configure pre-commit hooks
```sh
pre-commit install
```

### Tests

- Tests are available in `test` directory
- In the test directory, run the below command
```sh
go test
```

