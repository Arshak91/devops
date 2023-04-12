#!/bin/bash

function createGatewayAndAttachVpc() {
    igw_name="$1 Gateway"
    vpcId=$2
    gatewayId=0
    gateway_response=$(aws ec2 create-internet-gateway \
	--output json)

    gatewayId=$(echo -e "$gateway_response" |  /usr/bin/jq '.InternetGateway.InternetGatewayId' | tr -d '"')

    #add name the internet gateway
    $(aws ec2 create-tags \
    --resources "$gatewayId" \
    --tags Key=Name,Value="$igw_name")

    #attach gateway to vpc
    attach_response=$(aws ec2 attach-internet-gateway \
    --internet-gateway-id "$gatewayId"  \
    --vpc-id "$vpcId")
}