#!bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"


stringIds=$( cat "$SCRIPT_DIR/ids.txt" )
arr=($stringIds)
IFS=', ' read -a arr <<< "$stringIds"

for i in "${arr[@]}"
do
   echo $i
done

# echo ${arr[1]}
#!/bin/bash

# Set the instance ID of the EC2 instance to be terminated
INSTANCE_ID="i-0123456789abcdefg"

# Terminate the EC2 instance
aws ec2 terminate-instances --instance-ids $INSTANCE_ID

# Wait for the instance to be terminated
aws ec2 wait instance-terminated --instance-ids $INSTANCE_ID

# Delete all associated services
aws ec2 delete-security-group --group-name my-security-group
aws ec2 disassociate-route-table --association-id $routeTableAssocId
aws ec2 describe-route-tables --route-table-ids $rtbId
aws ec2 delete-subnet --subnet-id subnet-0123456789abcdefg
aws ec2 delete-vpc --vpc-id vpc-0123456789abcdefg