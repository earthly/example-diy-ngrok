#!/usr/bin/env bash

KEY_NAME="reverse_proxy"

echo "Creating EC2 Key Pair..."
aws ec2 create-key-pair \
    --key-name $KEY_NAME \
    > key-output.json

KEY_ID=$(jq -r .KeyPairId key-output.json)
jq -r .KeyMaterial key-output.json > key.pem

VPC_ID=$(aws ec2 describe-subnets | jq -r ".Subnets[] | select(.SubnetId==\"$SUBNET_ID\") | .VpcId")
echo "Found VPC ID for $SUBNET_ID: $VPC_ID"

echo "Creating EC2 Security Group..."
aws ec2 create-security-group \
    --group-name reverse-proxy \
    --description reverse-proxy \
    --vpc-id $VPC_ID \
    > sg-output.json

SG_ID=$(jq -r .GroupId sg-output.json)
CIDR=$(curl -s https://checkip.amazonaws.com)/32

echo "Configuring EC2 Security Group..."
aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 22 \
    --cidr $CIDR \
    --no-cli-pager

aws ec2 authorize-security-group-ingress \
    --group-id $SG_ID \
    --protocol tcp \
    --port 80 \
    --cidr 0.0.0.0/0 \
    --no-cli-pager

echo "Starting EC2 Instance..."
aws ec2 run-instances \
    --image-id resolve:ssm:/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 \
    --count 1 \
    --instance-type t2.micro \
    --key-name $KEY_NAME \
    --security-group-ids $SG_ID \
    --subnet-id $SUBNET_ID \
    > ec2-output.json

EC2_ID=$(jq -r '.Instances[0].InstanceId' ec2-output.json)

cat << EOF > resources.json
{
    "EC2_ID": "$EC2_ID",
    "KEY_ID": "$KEY_ID",
    "SG_ID": "$SG_ID"
}
EOF

echo "Waiting for Instance to Start..."
aws ec2 wait instance-status-ok --instance-ids $EC2_ID

EC2_PUBLIC=$(aws ec2 describe-instances --instance-ids $EC2_ID | jq -r ".Reservations[].Instances[].PublicDnsName")
echo "Instance is running; public DNS is: $EC2_PUBLIC"

# echo "Configuring NGINX..."
# chmod 600 key.pem
# ssh -o 'StrictHostKeyChecking=accept-new' -i key.pem ec2-user@$EC2_PUBLIC 'sudo amazon-linux-extras install nginx1'

# PORT="8080"

# sed -i "s/PORT/$PORT/g" server.conf
# sed -i "s/PUBLIC_DNS/$EC2_PUBLIC/g" server.conf
# cat server.conf
# scp -i key.pem server.conf ec2-user@$EC2_PUBLIC:/home/ec2-user

# ssh -i key.pem ec2-user@$EC2_PUBLIC 'sudo cp /home/ec2-user/server.conf /etc/nginx/conf.d/server.conf'

# echo "Starting NGINX..."
# ssh -i key.pem ec2-user@$EC2_PUBLIC 'sudo service nginx start'