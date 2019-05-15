#!/usr/bin/env bash

#echo $(aws cloudformation describe-stacks)
for BUCKET in $(aws s3api list-buckets --query "Buckets[].Name")
do
    if [[ $BUCKET == *"-tmp-"* ]]; then
        echo "I found one. Time to delete a bucket: ${BUCKET}.  Bye-Bye!"
        aws s3 rb s3://$BUCKET --force 
    fi
done

for STACK in $(aws cloudformation describe-stacks --region us-east-1 | ./jq -r '.Stacks[].StackName')
do
    if [[ $STACK == *"-tmp-"* ]]; then
        echo "I found one. Time to delete stack: ${STACK}.  Bye-Bye!"
        aws cloudformation delete-stack --stack-name $STACK
    fi
done

#echo $(aws cloudformation describe-stacks)
for STACK in $(aws cloudformation describe-stacks --region us-west-1 | ./jq -r '.Stacks[].StackName')
do
    if [[ $STACK == *"-tmp-"* ]]; then
        echo "I found one. Time to delete stack: ${STACK}.  Bye-Bye!"
        aws cloudformation delete-stack --region us-west-1 --stack-name $STACK
    fi
done