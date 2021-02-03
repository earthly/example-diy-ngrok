FROM amazon/aws-cli:2.1.23

ARG AWS_PROFILE=default
ARG AWS_REGION

RUN yum -y install jq openssh-clients

build-proxy:
    ARG SUBNET_ID
    
    COPY . .
    RUN --mount=type=secret,target=/root/.aws/config,id=+secrets/config \
        --mount=type=secret,target=/root/.aws/credentials,id=+secrets/credentials \
        --no-cache \
        ./build.sh

    ENTRYPOINT ["./entrypoint.sh"]
    
    SAVE IMAGE proxy:latest

list-subnets:
    RUN --mount=type=secret,target=/root/.aws/config,id=+secrets/config \
        --mount=type=secret,target=/root/.aws/credentials,id=+secrets/credentials \
        --no-cache \
        aws ec2 describe-subnets | jq -r '.Subnets[] | "\(.AvailabilityZone)\t\(.CidrBlock)\t\(.SubnetId)"' | sort