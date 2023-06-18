#!/bin/bash

aws ec2 detach-internet-gateway \
    --internet-gateway-id $1 \
    --vpc-id $2

aws ec2 delete-internet-gateway --internet-gateway-id "$1"