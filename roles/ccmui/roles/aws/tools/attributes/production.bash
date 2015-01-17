#!/bin/bash -e

user='ec2-user'

master=''

slaves=(
    # ap-northeast-1

    'ec2-54-64-202-215.ap-northeast-1.compute.amazonaws.com'
    'ec2-54-64-211-141.ap-northeast-1.compute.amazonaws.com'
    'ec2-54-64-212-174.ap-northeast-1.compute.amazonaws.com'
    'ec2-54-64-212-220.ap-northeast-1.compute.amazonaws.com'
    'ec2-54-64-213-147.ap-northeast-1.compute.amazonaws.com'
    'ec2-54-64-213-159.ap-northeast-1.compute.amazonaws.com'
    'ec2-54-64-213-182.ap-northeast-1.compute.amazonaws.com'

    # eu-west-1

    'ec2-54-171-14-93.eu-west-1.compute.amazonaws.com'
    'ec2-54-171-2-215.eu-west-1.compute.amazonaws.com'
    'ec2-54-171-5-197.eu-west-1.compute.amazonaws.com'
    'ec2-54-77-120-96.eu-west-1.compute.amazonaws.com'
    'ec2-54-77-206-114.eu-west-1.compute.amazonaws.com'
    'ec2-54-77-224-254.eu-west-1.compute.amazonaws.com'

    # us-east-1

    'ec2-107-23-249-252.compute-1.amazonaws.com'
    'ec2-107-23-251-23.compute-1.amazonaws.com'
    'ec2-107-23-251-49.compute-1.amazonaws.com'
    'ec2-107-23-251-53.compute-1.amazonaws.com'
    'ec2-54-165-5-63.compute-1.amazonaws.com'
    'ec2-54-210-15-171.compute-1.amazonaws.com'
    'ec2-54-210-175-89.compute-1.amazonaws.com'
    'ec2-54-210-235-148.compute-1.amazonaws.com'
    'ec2-54-84-213-208.compute-1.amazonaws.com'
    'ec2-54-86-24-250.compute-1.amazonaws.com'
)

identityFile='/Volumes/Data/Data/Keys/ssh/adobe/aws/ccmui/production.pem'