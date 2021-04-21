provider "aws" {
  region = var.region
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"
}

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
    type : "primary",
    unique_name : "mondgodb-master",
    subnet_id : module.vpc.database_subnets[0]
    }, {
    type : "secondary",
    unique_name : "mondgodb-replica",
    subnet_id : module.vpc.database_subnets[1]
  }]

}
