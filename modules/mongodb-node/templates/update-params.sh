#!/bin/bash
export AWS_DEFAULT_REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)

local_ip=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

if [ "${node_name}" != "" ]; then
  echo "Updating CloudMap"
  service_id=$(aws servicediscovery list-services | jq -r '.Services[] | select(.Name=="${node_name}") | .Id')
  aws servicediscovery register-instance --service-id "$service_id" --instance-id "ec2" --attributes=AWS_INSTANCE_IPV4="$local_ip"
else
  echo "Updating Parameter Store"
  aws ssm put-parameter --name "${hostname_ssm_path}" --value "$local_ip" --overwrite
fi
