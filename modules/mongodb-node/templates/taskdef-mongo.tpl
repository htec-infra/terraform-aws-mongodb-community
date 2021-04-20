[
  {
    "name": "mongodb",
    "image": "bitnami/mongodb:${mongodb_version}",
    "cpu": ${mongodb_container_cpu},
    "memory": ${mongodb_container_memory},
    "volumesFrom": [],
    "essential": true,
    "environment": ${envs},
    "secrets": ${secrets},
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": 27017,
        "hostPort": 27017
      }
    ],
    "mountPoints": [
      {
        "sourceVolume": "${volume_name}",
        "containerPath": "/bitnami/mongodb"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${loggroup_path}",
        "awslogs-region": "${app_region}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
