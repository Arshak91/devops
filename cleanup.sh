#!/bin/bash

vpc_id=vpc-0f1a769a3f868b2c3
igw=$(aws ec2 describe-internet-gateways --filters 'Name=attachment.vpc-id,Values='$vpc_id --output json)
igw_id=$(echo -E "$igw" | /usr/bin/jq '.InternetGateways[0].InternetGatewayId' | tr -d '"')
echo $igw_id

#aws ec2 delete-internet-gateway --internet-gateway-id $igw_id


routeTable=$(aws ec2 describe-route-tables --filters 'Name=vpc-id,Values='$vpc_id --output json)

routeTables=$(echo -e "$routeTable" | /usr/bin/jq '.RouteTables' | tr -d '"')

routeTableArr=$(echo "$routeTable" | /usr/bin/jq -r '.[]"\(.RouteTableId) , \(.VpcId)"')

declare -A map1

while read routeTableId vpcId ; do
	echo "$routeTableId"
	echo "$vpcId"

echo "${routeTableArr}"

#echo ${routeTableArr[1]}
#for i in "${routeTableArr[@]}"
#do
#	echo "$i" "${routeTableArr[$i]}"
#done
#echo $igw_id
#aws ec2 delete-route-table --vpc-id vpc-0f1a769a3f868b2c3

#aws ec2 delete-subnet --vpc-id vpc-0f1a769a3f868b2c3

#aws ec2 delete-security-group --vpc-id security-group




#remVpc=$(aws ec2 delete-vpc --vpc-id vpc-0f1a769a3f868b2c3 --output json)
#echo $remVpc
