#!/bin/bash
set -x

var1=1
var2=2
echo $1
function myFunction() {
    echo "Hello"

echo $1 $2 $3
    local var1=3
    echo $var1
    return 1
}

myFunction 4 5 6
echo ${var1}