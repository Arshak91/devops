#!/bin/bash

availabilityZone="us-east-1a"
name="SC-Instance"
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

#add name VPC
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




#remVpc1=$(aws ec2 delete-vpc --vpc-id vpc-0952346ad750e9266)
#remVpc2=$(aws ec2 delete-vpc --vpc-id vpc-08fef98bcdef22387)

