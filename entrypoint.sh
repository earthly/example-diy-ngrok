#!/usr/bin/env bash

case "$1" in
    "--key")
    cat key.pem
    ;;
    "--destroy")
    exec ./delete.sh
    ;;
    "--resources")
    jq resources.json
    ;;
    "--proxy-cmd")
    ssh -i key.pem -R 8080:localhost:3000 ec2-user@$(jq .EC2_PUBLIC resources.json)
    ;;
    *)
    echo "Valid options: --key / --destroy / --resources / --proxy-cmd"
    exit 1
    ;;
esac