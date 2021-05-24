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

variable "resource_name_with_env_suffix" {
  type    = bool
  default = false
}

variable "tags" {
  type        = map(string)
  description = "Default tags to be attached for every resource in the module"
  default     = {}
}

variable "instance_type" {
  type        = string
  description = "Type of ECS container instance type"
}

variable "disable_mongodb_service" {
  description = "Whether to run MongoDB service or not"
  type        = bool
  default     = false
}

variable "mongodb_nodes" {
  type = list(object({
    type : string,
    unique_name : string,
    subnet_id : string,
  }))
  description = ""
}

variable "mongodb_container_cpu" {
  type        = number
  description = "CPU capacity required for mongo container ( 1024 == 1 cpu)"
  default     = 1024
}

variable "mongodb_version" {
  type        = string
  description = "Docker image version of mongo"
}

variable "mongodb_container_memory" {
  type        = number
  description = "Memory required for mongo container"
  default     = 1606
}

variable "mongodb_node_ingress_sgs" {
  type = list(object({
    id : string
    description : string
  }))
  default     = []
  description = "Security group id for container EC2 instance"
}

variable "mongodb_node_ingress_cidr_block" {
  description = "Allow ingress traffic to the MongoDB node from specified IP CIDRs"
  type        = list(string)
  default     = []
}

variable "mongodb_storage_size" {
  type        = number
  default     = 50
  description = "Size (GB) of the dedicated EBS for mongodb data"
}

variable "service_discovery_namespace_id" {
  description = "The ID of the namespace to use for DNS configuration."
  type        = string
  default     = null
}

variable "private_root_domain" {
  description = "Service Discovery Domain name"
  type        = string
  default     = ""
}

