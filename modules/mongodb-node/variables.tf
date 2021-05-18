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

variable "resource_name_with_env_suffix" {
  type    = bool
  default = false
}

variable "tags" {
  type        = map(string)
  description = "Default tags to be attached for every resource in the module"
  default     = {}
}

variable "name" {
  type        = string
  description = "Base name for the cluster's node"
}

variable "private_root_domain" {
  type    = string
  default = ""
}

variable "primary_node_name" {
  type    = string
  default = "primary"
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

variable "mongodb_node_type" {
  type = string
  validation {
    condition     = contains(["standalone", "primary", "secondary"], var.mongodb_node_type)
    error_message = "Allowed values are 'primary' and 'secondary' at the moment."
  }
}

variable "mongodb_replica_set_key" {
  type    = string
  default = "appdata"
}

variable "mongodb_version" {
  type        = string
  description = "Docker image version of mongo"
}

variable "mongodb_container_cpu" {
  type        = number
  description = "CPU capacity required for mongo container ( 1024 == 1 cpu)"
  default     = 1024
}

variable "mongodb_container_memory" {
  type        = number
  description = "Memory required for mongo container"
  default     = 1606
}
variable "mongodb_storage_size" {
  type        = number
  default     = 50
  description = "Size (GB) of the dedicated EBS for mongodb data"
}

variable "additional_security_group_ids" {
  type        = list(string)
  default     = []
  description = "List of security groups attached to the MongoDB node"
}

variable "ecs_cluster_name" {
  type = string
}

variable "ecs_execution_role_arn" {
  type    = string
  default = null
}

variable "service_discovery_namespace_id" {
  description = "The ID of the namespace to use for DNS configuration."
  type        = string
  default     = null
}

variable "service_discovery_dns_record_type" {
  description = "The type of the resource, which indicates the value that Amazon Route 53 returns in response to DNS queries. One of `A` or `SRV`."
  type        = string
  default     = "A"
}

variable "service_discovery_dns_ttl" {
  description = "The amount of time, in seconds, that you want DNS resolvers to cache the settings for this resource record set."
  type        = number
  default     = 60
}

variable "service_discovery_routing_policy" {
  description = "The routing policy that you want to apply to all records that Route 53 creates when you register an instance and specify the service. One of `MULTIVALUE` or `WEIGHTED`."
  type        = string
  default     = "MULTIVALUE"
}

variable "service_discovery_failure_threshold" {
  description = "The number of 30-second intervals that you want service discovery to wait before it changes the health status of a service instance. Maximum value of 10."
  type        = number
  default     = 1
}
