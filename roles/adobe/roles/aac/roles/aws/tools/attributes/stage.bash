#!/bin/bash -e

export SSH_LOGIN='ec2-user'

export MASTER=''

export SLAVES=(
    # ap-northeast-1

    'ec2-52-68-64-45.ap-northeast-1.compute.amazonaws.com'
    'ec2-52-68-28-125.ap-northeast-1.compute.amazonaws.com'

    # eu-west-1

    'ec2-52-17-231-14.eu-west-1.compute.amazonaws.com'
    'ec2-52-16-48-161.eu-west-1.compute.amazonaws.com'

    # us-east-1

    'ec2-52-6-89-54.compute-1.amazonaws.com'
    'ec2-52-1-53-107.compute-1.amazonaws.com'
)

export IDENTITY_FILE='/Volumes/Data/Data/Keys/ssh/adobe/aws/aac/stage.pem'