#!/bin/bash


function createSubnet() {
    sub_name="$1 Subnet"
    subNetCidrBlock=$2
    availabilityZone=$3
    vpcId=$4
    subnetId=0
    #create Subnet
    subnet_response=$(aws ec2 create-subnet \
    --cidr-block "$subNetCidrBlock" \
    --availability-zone "$availabilityZone" \
    --vpc-id "$vpcId" \
    --output json)
    subnetId=$(echo -e "$subnet_response" |  /usr/bin/jq '.Subnet.SubnetId' | tr -d '"')

    #name the subnet
    aws ec2 create-tags \
    --resources "$subnetId" \
    --tags Key=Name,Value="$sub_name"

    #enable public ip on subnet
    modify_response=$(aws ec2 modify-subnet-attribute \
    --subnet-id "$subnetId" \
    --map-public-ip-on-launch)
    if [ "${subnetId}" == 0 ]; then
        message="create Subnet Error"
    fi
}