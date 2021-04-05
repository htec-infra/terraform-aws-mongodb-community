variable "namespace" {
  type        = string
  description = "Project namespace"
}

variable "environment" {
  type        = string
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

variable "subnet_id" {
  type        = string
  description = "Subnet identifier for MongoDB node"
}

variable "instance_type" {
  type        = string
  description = "MongoDB EC2 node instance type"
}

variable "instance_profile_arn" {
  type        = string
  description = "Instance profile that will be attached to the Mongo node"
}

variable "mongo_node_type" {
  type    = string
  default = "primary"
  validation {
    condition     = contains(["primary", "secondary"], var.mongo_node_type)
    error_message = "Allowed values are 'primary' and 'secondary' at the moment."
  }
}

variable "additional_security_group_ids" {
  type        = list(string)
  default     = []
  description = "List of security groups attached to the MongoDB node"
}
