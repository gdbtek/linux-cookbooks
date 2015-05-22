#!/bin/bash -e

export SSH_LOGIN='ec2-user'
export SSH_IDENTITY_FILE='/Volumes/Data/Data/Keys/ssh/adobe/aws/ccmui/stage.pem'

export MASTER=''

export SLAVES=(
    # ap-northeast-1

    'ec2-54-64-252-240.ap-northeast-1.compute.amazonaws.com'
    'ec2-54-65-74-19.ap-northeast-1.compute.amazonaws.com'

    # eu-west-1

    'ec2-54-171-65-136.eu-west-1.compute.amazonaws.com'
    'ec2-54-171-69-42.eu-west-1.compute.amazonaws.com'

    # us-east-1

    'ec2-52-1-127-174.compute-1.amazonaws.com'
    'ec2-54-152-132-115.compute-1.amazonaws.com'
    'ec2-54-86-19-3.compute-1.amazonaws.com'
)