#!/usr/bin/env bash

echo "Terminating instance..."
aws ec2 terminate-instances --no-cli-pager --instance-ids $(jq -r .EC2_ID resources.json) > /dev/null

echo "Waiting for instance termination..."
aws ec2 wait instance-terminated --no-cli-pager --instance-ids $(jq -r .EC2_ID resources.json)

echo "Deleting keypair..."
aws ec2 delete-key-pair --no-cli-pager --key-pair-id  $(jq -r .KEY_ID resources.json)

echo "Deleting security group..."
aws ec2 delete-security-group --no-cli-pager --group-id $(jq -r .SG_ID resources.json)