#!/bin/bash

availabilityZone="us-east-1a"
name="Firsh_Instance"
vpcCidrBlock="10.0.0.0/16"
subNetCidrBlock="10.0.1.0/24"
port22CidrBlock="0.0.0.0/0"
destinationCidrBlock="0.0.0.0/0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

message="ok"
ids=""

source "$SCRIPT_DIR/createVpc.sh"
createVpc $name $vpcCidrBlock
echo "VPC created"
ids="$vpcId"

if [ "${vpcId}" != 0 ]; then
    #create Internet Gateway
    source "$SCRIPT_DIR/createGatewayAndAttachVpc.sh"
    createGatewayAndAttachVpc "$name" "$vpcId"
    echo "Internet Gateway created"
    ids="$gatewayId $ids"
    #create Subnet
    source "$SCRIPT_DIR/createSubnet.sh"
    createSubnet "$name" "$subNetCidrBlock" "$availabilityZone" "$vpcId"
    echo "Subnet created"
    ids="$subnetId $ids"
    #create security group
    source "$SCRIPT_DIR/createSecurityGroup.sh"
    createSecurityGroup "$name" "$port22CidrBlock" "$vpcId"
    echo "Security Group created"
    ids="$groupId $ids"
else
    echo $message
fi

echo "gatewayId   $gatewayId"
echo "subnetId   $subnetId"
if [ "$gatewayId" != 0  -a  "$subnetId" != 0  ]; then
    #create route table for vpc
    source "$SCRIPT_DIR/createRouteTable.sh"
    createRouteTable "$name" "$vpcId" "$gatewayId" "$subnetId" "$destinationCidrBlock"
    echo "Route Table created"
    ids="$routeTableId $ids"
else
    echo $message
fi

s3_instance=$(aws ec2 run-instances --tag-specifications \
    'ResourceType=instance,Tags=[{Key=Name,Value='$name'}]' \
    --image-id ami-007855ac798b5175e \
    --count 1 \
    --instance-type t2.micro \
    --key-name virginia \
    --security-group-ids $groupId \
    --subnet-id $subnetId \
--output json)
s3_instanceId=$(echo -e "$s3_instance" |  /usr/bin/jq '.Instances[0].InstanceId' | tr -d '"')
ids="$s3_instanceId $ids"
echo "$ids" > "$SCRIPT_DIR/ids.txt"
echo $s3_instance


echo "Instance Created"