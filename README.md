# MongoDB Cluster on ECS

## Overview

Community MongoDB Cluster module developed on top of [Bitnami MongoDB](https://github.com/bitnami/bitnami-docker-mongodb) docker image. 
Each node has dedicated AutoScaling group and EBS volume, so node-related changes will affect specific node only, not entire cluster.

### Features
 - Autoscaling group and EBS volume per node
 - EC2 instance self-healing
 - Mechanism for reattaching EBS volume after EC2 termination
 - [WIP] Route53 auto update

## Usage

```terraform
module "mongodb_cluster" {
  source = "github.com/htec-infra/terraform-mongodb-community"

  namespace                = "ProjectName"
  environment              = "Development"
  env_code                 = "dev"
  name                     = "mongodb-cluster"
  instance_type            = "t3.medium"
  mongodb_version          = "4.4.5"
  mongodb_storage_size     = 100
  mongodb_container_cpu    = 2048
  mongodb_container_memory = 3600

  mongodb_nodes = [{
    type: "primary",
    unique_name: "mondgodb-master",
    subnet_id:  "subnet-12345abcd"
  }, {
    type: "secondary",
    unique_name: "mondgodb-replica",
    subnet_id:  "subnet-67890efgh"    
  }]

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

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_mongodb_nodes"></a> [mongodb\_nodes](#module\_mongodb\_nodes) | ./modules/mongodb-node |  |

## Resources

| Name | Type |
|------|------|
| [aws_ecs_cluster.mongodb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_iam_instance_profile.ecs_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.ecs_instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ecs_tasks_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ecs_tasks_inline_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.mongodb_node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ecs_instance_role_policy_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_instance_ssm_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_tasks_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group.mongodb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ssm_parameter.mongo_dba_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [random_password.mongo_dba](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_iam_policy_document.ecs_instance_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.mongodb_ecs_task_inline](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.mongodb_node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.mongodb_tasks_execution_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_subnet.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env_code"></a> [env\_code](#input\_env\_code) | Short environment name tag (e.g. dev, stg, prod) | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment indicator where the MongoDB will be instantiated. E.g. Development, Staging, QA, Production | `string` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Type of ECS container instance type | `string` | n/a | yes |
| <a name="input_mongodb_container_cpu"></a> [mongodb\_container\_cpu](#input\_mongodb\_container\_cpu) | CPU capacity required for mongo container ( 1024 == 1 cpu) | `number` | `1024` | no |
| <a name="input_mongodb_container_memory"></a> [mongodb\_container\_memory](#input\_mongodb\_container\_memory) | Memory required for mongo container | `number` | `1606` | no |
| <a name="input_mongodb_node_allow_intranet_access"></a> [mongodb\_node\_allow\_intranet\_access](#input\_mongodb\_node\_allow\_intranet\_access) | Allow traffic between mongodb and applications inside the VPC | `bool` | `false` | no |
| <a name="input_mongodb_node_ingress_sgs"></a> [mongodb\_node\_ingress\_sgs](#input\_mongodb\_node\_ingress\_sgs) | Security group id for container EC2 instance | <pre>list(object({<br>    id : string<br>    description : string<br>  }))</pre> | `[]` | no |
| <a name="input_mongodb_nodes"></a> [mongodb\_nodes](#input\_mongodb\_nodes) | n/a | <pre>list(object({<br>    type : string,<br>    unique_name : string,<br>    subnet_id : string,<br>  }))</pre> | n/a | yes |
| <a name="input_mongodb_storage_size"></a> [mongodb\_storage\_size](#input\_mongodb\_storage\_size) | Size (GB) of the dedicated EBS for mongodb data | `number` | `50` | no |
| <a name="input_mongodb_version"></a> [mongodb\_version](#input\_mongodb\_version) | Docker image version of mongo | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Base name for the cluster and other resources | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Project namespace | `string` | n/a | yes |
| <a name="input_private_root_domain"></a> [private\_root\_domain](#input\_private\_root\_domain) | Service Discovery Domain name | `string` | `""` | no |
| <a name="input_resource_name_with_env_suffix"></a> [resource\_name\_with\_env\_suffix](#input\_resource\_name\_with\_env\_suffix) | n/a | `bool` | `false` | no |
| <a name="input_service_discovery_namespace_id"></a> [service\_discovery\_namespace\_id](#input\_service\_discovery\_namespace\_id) | The ID of the namespace to use for DNS configuration. | `string` | `null` | no |
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

