variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "custom_policies" {
  description = "List of the custom policies"
  type = list(object({
    name        = string
    policy      = any
    path        = optional(string)
    description = optional(string)
    tags        = optional(any)
  }))
  default = []
}

variable "existing_policy_names" {
  description = "List of the names to existing policies"
  type = list(object({
    name = string
  }))
  default = []
}

variable "custom_roles_instance_profile" {
  description = "List of the custom roles to attach instance profile"
  type = list(object({
    name            = string
    policy          = any
    tags            = optional(any)
    attach_instance = optional(bool, true)
  }))
  default = []
}

variable "existing_role_names" {
  description = "List of the names to existing roles"
  type = list(object({
    name            = string
    attach_instance = optional(bool, true)
  }))
  default = []
}

variable "groups" {
  description = "List of the groups"
  type = list(object({
    name = string
  }))
  default = []
}

variable "user_name" {
  description = "User name"
  type        = string
  default     = null
}

variable "group_name" {
  description = "Group name"
  type        = string
  default     = null
}

variable "make_credentials" {
  description = "If true will make the AWS credentials"
  type        = bool
  default     = true
}

variable "allow_console_access" {
  description = "If true will allow AWS console access"
  type        = bool
  default     = false
}

variable "password_reset_required" {
  description = "If true reset is required"
  type        = bool
  default     = true
}

variable "path_export_credentials" {
  description = "If defined will be export the credentials to this path"
  type        = string
  default     = null
}

variable "only_create_group" {
  description = "If true It's only create resources to groups, policies and attachments"
  type        = bool
  default     = false
}

variable "ou_name" {
  description = "Organization unit name"
  type        = string
  default     = "no"
}

variable "use_tags_default" {
  description = "If true will be use the tags default"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to API Gateway"
  type        = map(any)
  default     = {}
}
