#!/bin/bash -e

export SSH_LOGIN='root'
export SSH_IDENTITY_FILE='/Volumes/Data/Data/Keys/ssh/adobe/it-cloud/private.key'

export MASTER_SERVERS=(
    'ccmapi-jenkins.corp.adobe.com'
)

export SLAVE_SERVERS=(
    'ccmapi-jenkins-slave-1.corp.adobe.com'
    'ccmapi-jenkins-slave-2.corp.adobe.com'
)