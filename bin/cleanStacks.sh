#!/usr/bin/env bash

for STACK in $(aws cloudformation describe-stacks --max-items 1000 | ./jq -r '.StackSummaries[].StackName')
do
    echo $STACK
done