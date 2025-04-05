locals {

  busbud_app_cluster_name        = "busbud-ecs-cluster"
  availability_zones             = ["us-east-1a", "us-east-1b"]
  frontend_task_famliy           = "frontend-web-task-def"
  container_port                 = 5000
  frontend_task_name             = "frontend-web-task"
  ecs_task_execution_role_name   = "ecsTaskExecutionRole"
  application_load_balancer_name = "load-balancer-frontend"
  target_group_name              = "lb-target-group"
  image_url                      = "sanjaya12345/devops-web:v1.68"
  frontend_service_name          = "busbud-frontend-service"

  backend_task_famliy            = "backend-api-task-def"
  backend_task_name              = "backend-api-task"
  backend_image_url              = "sanjaya12345/devops-api:v1.67"
  backend_service_name           = "busbud-backend-service"
  backend_container_port         = 5000
}