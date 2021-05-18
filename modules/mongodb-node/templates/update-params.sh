#!/bin/bash
export AWS_DEFAULT_REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
local_ip=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

echo "Updating Parameter Store"
aws ssm put-parameter --name "${hostname_ssm_path}" --value "$local_ip" --overwrite
