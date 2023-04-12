#!/bin/bash


function createSecurityGroup() {
    scg_name="$1 Security Group"
    portCidrBlock=$2
    vpcId=$3
    groupId=0
    security_response=$(aws ec2 create-security-group \
        --group-name "$scg_name" \
        --description "Private: $scg_name" \
        --vpc-id "$vpcId" --output json
    )
    groupId=$(echo -e "$security_response" |  /usr/bin/jq '.GroupId' | tr -d '"')

    #name the security group
    aws ec2 create-tags \
    --resources "$groupId" \
    --tags Key=Name,Value="$scg_name"
    #enable port 22

    security_response2=$(aws ec2 authorize-security-group-ingress \
        --group-id "$groupId" \
        --protocol all
    )
    if [ "${groupId}" == 0 ]; then
        message="create Security Group Error"
    fi
}