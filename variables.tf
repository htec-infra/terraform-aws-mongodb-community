variable "namespace" {
  type = string
  description = "Project namespace"
}

variable "environment" {
  type = string
  description = "Environment indicator where the MongoDB will be instantiated. E.g. Development, Staging, QA, Production"
}

variable "env_code" {
  type        = string
  description = "Short environment name tag (e.g. dev, stg, prod)"
}


variable "name" {
  type        = string
  description = "Base name for the cluster and other resources"
}

variable "tags" {
  type        = map(string)
  description = "Default tags to be attached for every resource in the module"
  default     = {}
}

variable "region" {
  type        = string
  description = "Region in which resources should be created"
}

variable "instance_type" {
  type        = string
  description = "Type of ECS container instance type"
}

variable "mongo_container_cpu" {
  type        = number
  description = "CPU capacity required for mongo container ( 1024 == 1 cpu)"
  default = 1024
}

variable "mongo_version" {
  type        = string
  description = "Docker image version of mongo"
}

variable "mongo_container_memory" {
  type        = number
  description = "Memory required for mongo container"
  default     = 1606
}

variable "security_group_id" {
  type        = string
  description = "Security group id for container EC2 instance"
}

variable "subnet_id" {
  type        = string
  description = "Subnet id for container EC2 instance"
}