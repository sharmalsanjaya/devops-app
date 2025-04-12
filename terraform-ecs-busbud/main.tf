module "network" {
  source = "./modules/network"
  availability_zones    = local.availability_zones
}

module "ecs" {
  source = "./modules/ecs"
  busbud_app_cluster_name = local.busbud_app_cluster_name
  subnet_ids              = module.network.subnet_ids
  vpc_id                  = module.network.vpc_id
  ecs_task_execution_role_name = local.ecs_task_execution_role_name
  application_load_balancer_name = local.application_load_balancer_name
  target_group_name              = local.target_group_name

  frontend_service_name          = local.frontend_service_name
  frontend_task_famliy           = local.frontend_task_famliy
  image_url                      = local.image_url
  frontend_task_name             = local.frontend_task_name
  container_port                 = local.container_port

  backend_service_name           = local.backend_service_name
  backend_task_famliy            = local.backend_task_famliy
  backend_image_url              = local.backend_image_url
  backend_task_name              = local.backend_task_name
  backend_container_port         = local.backend_container_port
}

#Log the load balancer app URL
output "app_url" {
  value = module.ecs.alb_dns_name
  description = "The DNS name of the Application Load Balancer from ecs module"
}