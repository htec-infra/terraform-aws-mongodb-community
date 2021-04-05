[
  {
    "name": "mongodb",
    "image": "docker.io/mongo:${mongodb_version}",
    "cpu": ${mongodb_container_cpu},
    "memory": ${mongodb_container_memory},
    "essential": true,
    "environment": [{
       "name": "MONGO_INITDB_ROOT_USERNAME",
       "value": "mongo_dba"
    }],
    "secrets": [{
        "name": "MONGO_INITDB_ROOT_PASSWORD",
        "valueFrom": "${mongodb_password_src}"
    }],
    "portMappings": [
      {
        "containerPort": 27017,
        "hostPort": 27017
      }
    ],
    "mountPoints": [
      {
        "sourceVolume": "${volume_name}",
        "containerPath": "/data/db"
      }
    ]
  }
]
