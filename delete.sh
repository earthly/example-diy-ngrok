#!/usr/bin/env bash

echo "Terminating instance..."
aws ec2 terminate-instances --quiet --instance-ids $(jq -r .EC2_ID resources.json)

echo "Waiting for instance termination..."
aws ec2 wait instance-terminated --instance-ids $(jq -r .EC2_ID resources.json)

echo "Deleting keypair..."
aws ec2 delete-key-pair --quiet --key-pair-id  $(jq -r .KEY_ID resources.json)

echo "Deleting security group..."
aws ec2 delete-security-group --group-id ---quiet $(jq -r .SG_ID resources.json)