#!/usr/bin/env bash

echo $(aws cloudformation describe-stacks)
for STACK in $(aws cloudformation describe-stacks | ./jq -r '.Stacks[].StackName')
do
    echo $STACK
done