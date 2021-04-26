#!/bin/bash

aws ssm put-parameter --name ${hostname_ssm_path} --value "$(hostname -I | awk '{print $1}')" --region ${region} --overwrite
