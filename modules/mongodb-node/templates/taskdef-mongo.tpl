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
    "portMappings": [],
    "entryPoint": [
      "/bin/bash",
      "-c",
      "while ! wait-for-port --host \"$MONGODB_ADVERTISED_HOSTNAME\" -s free 27017; do sleep 1; done && /opt/bitnami/scripts/mongodb/entrypoint.sh /opt/bitnami/scripts/mongodb/run.sh"
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

