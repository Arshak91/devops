#!bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"


stringIds=$( cat "$SCRIPT_DIR/ids.txt" )
arr=($stringIds)

for i in "${arr[@]}"
do
   echo "$i"
   case $i in *"i-"*)
      aws ec2 terminate-instances --instance-ids "$i"
      aws ec2 wait instance-terminated --instance-ids "$i"
   esac
   case $i in *"sg-"*)
      aws ec2 delete-security-group --group-id $i
   esac
   case $i in *"rtb-"*)
      source $SCRIPT_DIR/cleanUpInstance/removeRouteTable.sh "$i"
   esac
   case $i in *"subnet-"*)
      aws ec2 delete-subnet --subnet-id "$i"
   esac
   case $i in *"igw-"*)
      igw=$i
   esac
   case $i in *"vpc-"*)
      source $SCRIPT_DIR/cleanUpInstance/detachIGW.sh "$igw" "$i"
      aws ec2 delete-vpc --vpc-id "$i"
   esac
done
