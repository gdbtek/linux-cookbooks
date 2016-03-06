#!/bin/bash -e

export SSH_LOGIN='root'
export SSH_IDENTITY_FILE='/Volumes/Data/Data/Keys/ssh/adobe/it-cloud/private.key'

export MASTER_SERVERS=(
    'ccmui-jenkins.corp.adobe.com'
)

export SLAVE_SERVERS=(
    'ccmui-jenkins-slave-1.corp.adobe.com'
    'ccmui-jenkins-slave-2.corp.adobe.com'
    'ccmui-jenkins-slave-3.corp.adobe.com'
)