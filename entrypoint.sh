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
    *)
    echo "Valid options: --key / --destroy / --resources"
    exit 1
    ;;
esac