#!/usr/bin/env bash

case "$1" in
    "--key")
    cat /aws/key.pem
    ;;
    "--destroy")
    exec /aws/delete.sh
    ;;
    "--resources")
    jq . /aws/resources.json
    ;;
    "--proxy-cmd")
    echo "ssh -i key.pem -R 8080:localhost:3000 ec2-user@$(jq .EC2_PUBLIC /aws/resources.json)"
    ;;
    *)
    echo "Valid options: --key / --destroy / --resources / --proxy-cmd"
    exit 1
    ;;
esac