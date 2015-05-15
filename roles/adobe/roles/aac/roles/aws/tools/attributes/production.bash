#!/bin/bash -e

export user='ec2-user'

export master=''

export slaves=(
    # ap-northeast-1

    'ec2-52-68-9-36.ap-northeast-1.compute.amazonaws.com'
    'ec2-52-68-68-185.ap-northeast-1.compute.amazonaws.com'
    'ec2-52-68-144-120.ap-northeast-1.compute.amazonaws.com'

    # eu-west-1

    'ec2-52-17-188-101.eu-west-1.compute.amazonaws.com'
    'ec2-52-17-128-219.eu-west-1.compute.amazonaws.com'
    'ec2-52-16-228-89.eu-west-1.compute.amazonaws.com'

    # us-east-1

    'ec2-52-6-212-79.compute-1.amazonaws.com'
    'ec2-52-6-155-176.compute-1.amazonaws.com'
    'ec2-52-0-58-187.compute-1.amazonaws.com'
)

export identityFile='/Volumes/Data/Data/Keys/ssh/adobe/aws/aac/production.pem'