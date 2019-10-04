#!/usr/bin/env bash

LEGACY=0
LITE=0
PRO=0
WESTCOAST=0
ENTERPRISE=0
DOCKER=1
MARKETPLACE=1

if [ $LEGACY == 1 ]; then
    echo "Create Legacy Stacks:" 
    echo "Create Solodev Pro for Opsworks Legacy"
    echo $(aws s3 cp s3://build-secure/params/solodev-pro-classic.json - ) > solodev-pro-classic.json
    aws cloudformation create-stack --disable-rollback --stack-name pro-legacy-tmp-${DATE} --disable-rollback --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
        --parameters file:///${CODEBUILD_SRC_DIR}/solodev-pro-classic.json \
        --template-url https://s3.amazonaws.com/solodev-aws-ha/legacy/solodev-pro-opsworks.json \
        --notification-arns $NOTIFICATION_ARN
    echo "Create Solodev Enterprise for Opsworks Legacy"
    echo $(aws s3 cp s3://build-secure/params/solodev-enterprise-classic.json - ) > solodev-enterprise-classic.json
    aws cloudformation create-stack --disable-rollback --stack-name enterprise-legacy-tmp-${DATE} --disable-rollback --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM
        --parameters file:///${CODEBUILD_SRC_DIR}/solodev-enterprise-classic.json
        --template-url https://s3.amazonaws.com/solodev-aws-ha/legacy/solodev-enterprise-opsworks.json
        --notification-arns $NOTIFICATION_ARN
fi

if [ $LITE == 1 ]; then
    echo "Create Solodev Lite"
    echo $(aws s3 cp s3://build-secure/params/solodev-lite-single.json - ) > solodev-lite-single.json
    aws cloudformation create-stack --disable-rollback --stack-name lite-tmp-${DATE} --disable-rollback --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
        --parameters file:///${CODEBUILD_SRC_DIR}/solodev-lite-single.json \
        --template-url https://s3.amazonaws.com/solodev-aws-ha/aws/solodev-lite-linux.yaml \
        --notification-arns $NOTIFICATION_ARN
fi

if [ $PRO == 1 ]; then
    echo "Create Solodev Pro for Opsworks"
    echo $(aws s3 cp s3://build-secure/params/solodev-pro-single.json - ) > solodev-pro-single.json
    aws cloudformation create-stack --disable-rollback --stack-name pro-tmp-${DATE} --disable-rollback --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
        --parameters file:///${CODEBUILD_SRC_DIR}/solodev-pro-single.json \
        --template-url https://s3.amazonaws.com/solodev-aws-ha/aws/solodev-pro-opsworks.yaml \
        --notification-arns $NOTIFICATION_ARN
    echo "Create Solodev Pro for Opsworks BYOL"
    echo $(aws s3 cp s3://build-secure/params/solodev-pro-single.json - ) > solodev-pro-single-byol.json
    aws cloudformation create-stack --disable-rollback --stack-name pro-byol-tmp-${DATE} --disable-rollback --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
        --parameters file:///${CODEBUILD_SRC_DIR}/solodev-pro-single-byol.json \
        --template-url https://s3.amazonaws.com/solodev-aws-ha/aws/solodev-pro-opsworks-byol.yaml \
        --notification-arns $NOTIFICATION_ARN
fi

if [ $WESTCOAST == 1 ]; then
    echo "Create Solodev Pro for Opsworks - California"
    echo $(aws s3 cp s3://build-secure/params/solodev-pro-opsworks-us-west-1.json - ) > solodev-pro-single.json
    aws cloudformation create-stack --region us-west-1 --disable-rollback --stack-name pro-tmp-${DATE}-west --disable-rollback --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
        --parameters file:///${CODEBUILD_SRC_DIR}/solodev-pro-single.json \
        --template-url https://s3.amazonaws.com/solodev-aws-ha/aws/solodev-pro-opsworks.yaml \
        --notification-arns $NOTIFICATION_ARN
    echo "Create Solodev Pro for Opsworks BYOL - California"
    echo $(aws s3 cp s3://build-secure/params/solodev-pro-opsworks-us-west-1.json - ) > solodev-pro-single-byol.json
    aws cloudformation create-stack --region us-west-1 --disable-rollback --stack-name pro-byol-tmp-${DATE}-west --disable-rollback --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
        --parameters file:///${CODEBUILD_SRC_DIR}/solodev-pro-single-byol.json \
        --template-url https://s3.amazonaws.com/solodev-aws-ha/aws/solodev-pro-opsworks-byol.yaml \
        --notification-arns $NOTIFICATION_ARN
fi

if [ $ENTERPRISE == 1 ]; then
    echo "Create Solodev Enterprise for Opsworks"
    echo $(aws s3 cp s3://build-secure/params/solodev-enterprise-opsworks.json - ) > solodev-enterprise-opsworks.json
    aws cloudformation create-stack --disable-rollback --stack-name ops-tmp-${DATE} --disable-rollback --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
        --parameters file:///${CODEBUILD_SRC_DIR}/solodev-enterprise-opsworks.json \
        --template-url https://s3.amazonaws.com/solodev-aws-ha/aws/solodev-enterprise-opsworks.yaml \
        --notification-arns $NOTIFICATION_ARN
    echo "Create Solodev Enterprise for Opsworks BYOL"
    echo $(aws s3 cp s3://build-secure/params/solodev-enterprise-opsworks.json - ) > solodev-enterprise-opsworks.json
    aws cloudformation create-stack --disable-rollback --stack-name ops-byol-tmp-${DATE} --disable-rollback --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
        --parameters file:///${CODEBUILD_SRC_DIR}/solodev-enterprise-opsworks.json \
        --template-url https://s3.amazonaws.com/solodev-aws-ha/aws/solodev-enterprise-opsworks-byol.yaml \
        --notification-arns $NOTIFICATION_ARN
fi

if [ $DOCKER == 1 ]; then
    echo "Create Solodev Enterprise for Docker (DockerHub)"
    echo $(aws s3 cp s3://build-secure/params/solodev-enterprise-ecs-dev.json - ) > solodev-enterprise-ecs-dev.json
    aws cloudformation create-stack --disable-rollback --stack-name ecs-dev-tmp-${DATE} --disable-rollback --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
        --parameters file:///${CODEBUILD_SRC_DIR}/solodev-enterprise-ecs-dev.json \
        --template-url https://s3.amazonaws.com/solodev-aws-ha/aws/solodev-enterprise-ecs.dev.yaml \
        --notification-arns $NOTIFICATION_ARN
fi

if [ $MARKETPLACE == 1 ]; then
    # echo "Create Marketplace Solodev Lite"
    # echo $(aws s3 cp s3://build-secure/params/solodev-lite-single.json - ) > solodev-lite-single.json
    # aws cloudformation create-stack --disable-rollback --stack-name mp-lite-tmp-${DATE} --disable-rollback --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
    #     --parameters file:///${CODEBUILD_SRC_DIR}/solodev-lite-single.json \
    #     --template-url https://s3.amazonaws.com/awsmp-fulfillment-cf-templates-prod/44f2ab80-ed37-4b80-a5ce-81defb0ca8b7.359a0410-0e42-4901-a26c-8b03fc331fa1.template \
    #     --notification-arns $NOTIFICATION_ARN
    # echo "Create Marketplace Solodev Pro for Opsworks"
    # echo $(aws s3 cp s3://build-secure/params/solodev-pro-single.json - ) > solodev-pro-single.json
    # aws cloudformation create-stack --disable-rollback --stack-name mp-pro-tmp-${DATE} --disable-rollback --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
    #     --parameters file:///${CODEBUILD_SRC_DIR}/solodev-pro-single.json \
    #     --template-url https://s3.amazonaws.com/awsmp-fulfillment-cf-templates-prod/980a6581-20fe-44fc-9294-f699808ca56b.1df4596b-dc73-4972-913f-50b7b53f29e0.template \
    #     --notification-arns $NOTIFICATION_ARN
    # echo "Create Marketplace Solodev Pro for Opsworks BYOL"
    # echo $(aws s3 cp s3://build-secure/params/solodev-pro-single.json - ) > solodev-pro-single-byol.json
    # aws cloudformation create-stack --disable-rollback --stack-name mp-pro-byol-tmp-${DATE} --disable-rollback --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
    #     --parameters file:///${CODEBUILD_SRC_DIR}/solodev-pro-single-byol.json \
    #     --template-url https://s3.amazonaws.com/awsmp-fulfillment-cf-templates-prod/61e198f6-4f84-49a2-89b8-0e269a1f0e99.cd206970-f449-4667-84b4-0392bfef1532.template \
    #     --notification-arns $NOTIFICATION_ARN
    # echo "Create Marketplace Solodev Enterprise for Opsworks"
    # echo $(aws s3 cp s3://build-secure/params/solodev-enterprise-opsworks.json - ) > solodev-enterprise-opsworks.json
    # aws cloudformation create-stack --disable-rollback --stack-name mp-ops-tmp-${DATE} --disable-rollback --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
    #     --parameters file:///${CODEBUILD_SRC_DIR}/solodev-enterprise-opsworks.json \
    #     --template-url https://s3.amazonaws.com/awsmp-fulfillment-cf-templates-prod/dcf914de-501b-45a0-abf0-3855314d2406.270f6e2a-36bb-4245-9567-2cbe79415b1b.template \
    #     --notification-arns $NOTIFICATION_ARN
    # echo "Create Marketplace Solodev Enterprise for Opsworks BYOL"
    # echo $(aws s3 cp s3://build-secure/params/solodev-enterprise-opsworks.json - ) > solodev-enterprise-opsworks.json
    # aws cloudformation create-stack --disable-rollback --stack-name mp-ops-byol-tmp-${DATE} --disable-rollback --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
    #     --parameters file:///${CODEBUILD_SRC_DIR}/solodev-enterprise-opsworks.json \
    #     --template-url https://s3.amazonaws.com/awsmp-fulfillment-cf-templates-prod/0a88415f-fbe6-4adf-af4b-699f96285513.70851900-9166-46dd-809d-7e8bec604989.template \
    #     --notification-arns $NOTIFICATION_ARN
    echo "Create Solodev Enterprise for Docker (MarketPlace)"
    echo $(aws s3 cp s3://build-secure/params/solodev-enterprise-ecs.json - ) > solodev-enterprise-ecs.json
    aws cloudformation create-stack --disable-rollback --stack-name mp-ecs-tmp-${DATE} --disable-rollback --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
        --parameters file:///${CODEBUILD_SRC_DIR}/solodev-enterprise-ecs.json \
        --template-url https://s3.amazonaws.com/solodev-aws-ha/aws/solodev-enterprise-ecs.yaml \
        --notification-arns $NOTIFICATION_ARN
fi