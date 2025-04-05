variable "busbud_app_cluster_name" {
  description = "ECS Cluster Name"
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "frontend_task_famliy" {
  description = "ECS Task Family"
  type        = string
}

variable "image_url" {
  description = "ECR Repo URL"
  type        = string
}

variable "container_port" {
  description = "Container Port"
  type        = number
}

variable "frontend_task_name" {
  description = "ECS Task Name"
  type        = string
}

variable "ecs_task_execution_role_name" {
  description = "ECS Task Execution Role Name"
  type        = string
}

variable "application_load_balancer_name" {
  description = "ALB Name"
  type        = string
}

variable "target_group_name" {
  description = "ALB Target Group Name"
  type        = string
}

variable "frontend_service_name" {
  description = "ECS Service Name"
  type        = string
}



variable "backend_task_famliy" {
  description = "Backend Task Family"
  type        = string

}
variable "backend_task_name" {
  description = "Backend Task Name"
  type        = string

}
variable "backend_image_url" {
  description = "Backend Image url"
  type        = string

}
variable "backend_service_name" {
  description = "Backend Service Name"
  type        = string
  
}

variable "backend_container_port" {
  description = "Backend Container Port"
  type        = number

}