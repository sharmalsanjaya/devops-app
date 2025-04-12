locals {

  busbud_app_cluster_name        = "busbud-ecs-cluster-tf"
  availability_zones             = ["us-east-2a", "us-east-2b"]
  frontend_task_famliy           = "frontend-web-task-def-tf"
  container_port                 = 5000
  frontend_task_name             = "frontend-web-task-tf"
  ecs_task_execution_role_name   = "ecsTaskExecutionRole"
  application_load_balancer_name = "load-balancer-frontend-tf"
  target_group_name              = "lb-target-group-tf"
  image_url                      = "sanjaya12345/busbud-frontend:0.1"
  frontend_service_name          = "busbud-frontend-service-tf"

  backend_task_famliy            = "backend-api-task-def-tf"
  backend_task_name              = "backend-api-task-tf"
  backend_image_url              = "sanjaya12345/busbud:0.1"
  backend_service_name           = "busbud-backend-service-tf"
  backend_container_port         = 3000
}