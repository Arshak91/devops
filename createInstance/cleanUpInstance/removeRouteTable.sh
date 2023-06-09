#!/bin/bash


route_table_response=$(aws ec2 describe-route-tables \
    --route-table-ids $1 \
    --output json \
)
routeTableAssocId=$(echo -e "$route_table_response" |  /usr/bin/jq '.RouteTables[0].Associations[0].RouteTableAssociationId' | tr -d '"')

aws ec2 disassociate-route-table --association-id $routeTableAssocId
aws ec2 delete-route-table --route-table-id "$1"