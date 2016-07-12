#!/bin/bash -e

export SSH_LOGIN='ec2-user'
export SSH_IDENTITY_FILE='/Volumes/Data/Data/Keys/ssh/adobe/aws/aac/production.pem'

export MASTER_SERVERS=(
    # ap-northeast-1

    'ec2-52-68-9-36.ap-northeast-1.compute.amazonaws.com'
    'ec2-52-68-68-185.ap-northeast-1.compute.amazonaws.com'
    'ec2-52-68-144-120.ap-northeast-1.compute.amazonaws.com'

    # eu-west-1

    'ec2-52-19-213-63.eu-west-1.compute.amazonaws.com'
    'ec2-52-51-18-254.eu-west-1.compute.amazonaws.com'
    'ec2-52-51-170-9.eu-west-1.compute.amazonaws.com'

    # us-east-1

    'ec2-52-6-155-176.compute-1.amazonaws.com'
    'ec2-52-0-58-187.compute-1.amazonaws.com'
    'ec2-54-237-231-97.compute-1.amazonaws.com'
)

export SLAVE_SERVERS=()
