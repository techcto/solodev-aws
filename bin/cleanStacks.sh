#!/usr/bin/env bash

#echo $(aws cloudformation describe-stacks)
for STACK in $(aws cloudformation describe-stacks | ./jq -r '.Stacks[].StackName')
do
    if [[ $STACK == *"-tmp-"* ]]; then
        echo "I found one. Time to delete stack: ${STACK}.  Bye-Bye!"
        aws cloudformation delete-stack --regions "us-east-1" "us-west-1" --stack-name $STACK
    fi
done