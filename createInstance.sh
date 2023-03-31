#!/bin/bash

availabilityZone="us-east-1a"
name="SC-Instance"
keyPairName="$name-KP"
vpcName="$name VPC"
subnetName="$name Subnet"
gatewayName="$name Gateway"
routeTableName="$name Route Table"
securityGroupName="$name Security Group"
vpcCidrBlock="10.0.0.0/16"
subNetCidrBlock="10.0.1.0/24"
port22CidrBlock="0.0.0.0/0"
destinationCidrBlock="0.0.0.0/0"

echo "Create VPC..."
#create VPC
aws_response=$(aws ec2 create-vpc \
	--cidr-block "$vpcCidrBlock" \
	--output json)

vpcId=$(echo -e "$aws_response" | /usr/bin/jq '.Vpc.VpcId' | tr -d '"')

#name the vpc
aws ec2 create-tags \
  --resources "$vpcId" \
  --tags Key=Name,Value="$vpcName"

#add dns support
modify_response=$(aws ec2 modify-vpc-attribute \
	--vpc-id "$vpcId" \
	--enable-dns-support "{\"Value\":true}")

#add dns hostnames
modify_response=$(aws ec2 modify-vpc-attribute \
	--vpc-id "$vpcId" \
	--enable-dns-hostnames "{\"Value\":true}")

#create Internet Gateway
gateway_response=$(aws ec2 create-internet-gateway \
	--output json)
echo "$gateway_response"
gatewayId=$(echo -e "$gateway_response" |  /usr/bin/jq '.InternetGateway.InternetGatewayId' | tr -d '"')

#add name the internet gateway
aws ec2 create-tags \
  --resources "$gatewayId" \
  --tags Key=Name,Value="$gatewayName"


#attach gateway to vpc

attach_response=$(aws ec2 attach-internet-gateway \
 --internet-gateway-id "$gatewayId"  \
 --vpc-id "$vpcId")

#create route table for vpc
route_table_response=$(aws ec2 create-route-table \
 --vpc-id "$vpcId" \
 --output json)
routeTableId=$(echo -e "$route_table_response" |  /usr/bin/jq '.RouteTable.RouteTableId' | tr -d '"')

#name the route table
aws ec2 create-tags \
  --resources "$routeTableId" \
  --tags Key=Name,Value="$routeTableName"

#add route for the internet gateway
route_response=$(aws ec2 create-route \
 --route-table-id "$routeTableId" \
 --destination-cidr-block "$destinationCidrBlock" \
 --gateway-id "$gatewayId")

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
  --tags Key=Name,Value="$subnetName"

#enable public ip on subnet
modify_response=$(aws ec2 modify-subnet-attribute \
 --subnet-id "$subnetId" \
 --map-public-ip-on-launch)

#create security group
security_response=$(aws ec2 create-security-group \
 --group-name "$securityGroupName" \
 --description "Private: $securityGroupName" \
 --vpc-id "$vpcId" --output json)
groupId=$(echo -e "$security_response" |  /usr/bin/jq '.GroupId' | tr -d '"')

#name the security group
aws ec2 create-tags \
  --resources "$groupId" \
  --tags Key=Name,Value="$securityGroupName"
#enable port 22

security_response2=$(aws ec2 authorize-security-group-ingress \
 --group-id "$groupId" \
 --protocol tcp --port 22 \
 --cidr "$port22CidrBlock")

#add route to subnet
associate_response=$(aws ec2 associate-route-table \
 --subnet-id "$subnetId" \
 --route-table-id "$routeTableId")

s3_instance=$(aws ec2 run-instances --tag-specifications \
    	'ResourceType=instance,Tags=[{Key=Name,Value='$name'}]' \
    	--image-id ami-007855ac798b5175e \
    	--count 1 \
    	--instance-type t2.micro \
    	--key-name virginia \
    	--security-group-ids $groupId \
    	--subnet-id $subnetId \
	--output json)


