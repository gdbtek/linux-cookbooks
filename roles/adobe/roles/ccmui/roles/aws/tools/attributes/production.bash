#!/bin/bash -e

export SSH_LOGIN='ec2-user'

export MASTER=''

export SLAVES=(
    # ap-northeast-1

    'ec2-54-65-251-26.ap-northeast-1.compute.amazonaws.com'
    'ec2-54-92-40-245.ap-northeast-1.compute.amazonaws.com'
    'ec2-54-92-49-186.ap-northeast-1.compute.amazonaws.com'
    'ec2-54-92-82-236.ap-northeast-1.compute.amazonaws.com'
    'ec2-54-92-88-46.ap-northeast-1.compute.amazonaws.com'
    'ec2-54-92-92-147.ap-northeast-1.compute.amazonaws.com'

    # eu-west-1

    'ec2-54-154-22-36.eu-west-1.compute.amazonaws.com'
    'ec2-54-154-27-103.eu-west-1.compute.amazonaws.com'
    'ec2-54-154-45-205.eu-west-1.compute.amazonaws.com'
    'ec2-54-72-42-233.eu-west-1.compute.amazonaws.com'
    'ec2-54-77-11-36.eu-west-1.compute.amazonaws.com'
    'ec2-54-77-162-240.eu-west-1.compute.amazonaws.com'

    # us-east-1

    'ec2-52-4-159-114.compute-1.amazonaws.com'
    'ec2-54-152-237-142.compute-1.amazonaws.com'
    'ec2-54-152-240-248.compute-1.amazonaws.com'
    'ec2-54-152-240-81.compute-1.amazonaws.com'
    'ec2-54-152-242-204.compute-1.amazonaws.com'
    'ec2-54-152-244-26.compute-1.amazonaws.com'
    'ec2-54-152-247-146.compute-1.amazonaws.com'
    'ec2-54-152-252-221.compute-1.amazonaws.com'
    'ec2-54-152-253-191.compute-1.amazonaws.com'
    'ec2-54-164-73-94.compute-1.amazonaws.com'
)

export IDENTITY_FILE='/Volumes/Data/Data/Keys/ssh/adobe/aws/ccmui/production.pem'