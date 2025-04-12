resource "aws_ecs_cluster" "busbud-cluster-tf" {
  name = var.busbud_app_cluster_name
}

resource "aws_ecs_task_definition" "frontend_task" {
  family                   = var.frontend_task_famliy
  container_definitions = jsonencode([
    {
      name      = var.frontend_task_name
      image     = var.image_url
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
        }
      ]
      memory = 512
      cpu    = 256
      environment = [
        {
          name  = "API_HOST"
          value = "http://backend.busbud.local:3000"
        }
      ]
    }
  ])

  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
}

resource "aws_ecs_task_definition" "backend-task" {
  family                   = var.backend_task_famliy
  container_definitions    = jsonencode([
    {
       name = var.backend_task_name
       image = var.backend_image_url
       essential = true,
       portMappings = [
        {
          containerPort = var.backend_container_port
          hostPort      = var.backend_container_port
          name          = "http" 
          appProtocol   = "http" 
               
        }
      ]
      memory = 512
      cpu    = 256
      environment = [
         {
            name  = "DB"
            value = "postgres://root:mysecretpassword@3.82.109.221:5432/postgres"
         }
      ]
    }
  ])

  requires_compatibilities = ["FARGATE"]  
  network_mode             = "awsvpc"     
  memory                   = 512           
  cpu                      = 256           
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
}
#-----------------------------------------------------------------------
resource "aws_service_discovery_private_dns_namespace" "busbud" {
  name        = "busbud.local"
  description = "Private DNS namespace for Busbud services"
  vpc         = var.vpc_id
}

#-----------------------------------------------------------------------

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = var.ecs_task_execution_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role" "ecs_task_role" {
  name               = "taskrole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_alb" "application_load_balancer" {
  name               = var.application_load_balancer_name
  load_balancer_type = "application"
  subnets = var.subnet_ids
  security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
}

resource "aws_security_group" "load_balancer_security_group" {
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "target_group" {
  name        = var.target_group_name
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

resource "aws_ecs_service" "frontend_service" {
  name            = var.frontend_service_name
  cluster         = aws_ecs_cluster.busbud-cluster-tf.id
  task_definition = aws_ecs_task_definition.frontend_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1
  enable_execute_command   = true

   load_balancer {
     target_group_arn = aws_lb_target_group.target_group.arn
     container_name   = var.frontend_task_name
     container_port   = var.container_port
   }


  network_configuration {
    subnets          = var.subnet_ids
    assign_public_ip = true
    security_groups  = ["${aws_security_group.service_security_group.id}"]
  }

    service_connect_configuration {
    enabled  = true
    namespace = aws_service_discovery_private_dns_namespace.busbud.arn

  }

  depends_on = [
    aws_lb_listener.listener,
    aws_alb.application_load_balancer
  ]
}


resource "aws_ecs_service" "busbud_backend_service" {
  name            = var.backend_service_name
  cluster         = aws_ecs_cluster.busbud-cluster-tf.id
  task_definition = aws_ecs_task_definition.backend-task.arn
  launch_type     = "FARGATE"
  desired_count   = 1  
  enable_execute_command   = true

  
  network_configuration {
    subnets          = var.subnet_ids
    assign_public_ip = true  # For Pull Image
    security_groups  = ["${aws_security_group.service_security_group.id}"]
  }
  service_connect_configuration {
    enabled  = true
    namespace = aws_service_discovery_private_dns_namespace.busbud.arn

    service  {
      port_name = "http"  # Must match container port name in task definition
      discovery_name = "backend"
      client_alias {
        port     = 3000
        
      }
    }
  }
}

resource "aws_security_group" "service_security_group" {
  name        = "busbud-service-sg"
  description = "Allow frontend-backend communication"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
    self            = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "backend_service_security_group" {
  name        = "busbud-backend-sg"
  description = "Allow traffic from frontend to backend"
  vpc_id      = var.vpc_id
  
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    security_groups = [aws_security_group.service_security_group.id]
    
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }
}
