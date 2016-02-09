#!/bin/bash -e

export SSH_LOGIN='root'
export SSH_IDENTITY_FILE='/Volumes/Data/Data/Keys/ssh/adobe/it-cloud/private.key'

export MASTER_SERVERS=(
    'ccpd-jenkins.corp.adobe.com'
)

export SLAVE_SERVERS=(
    'ccpd-jenkins-slave-1.corp.adobe.com'
    'ccpd-jenkins-slave-2.corp.adobe.com'
    'ccpd-jenkins-slave-3.corp.adobe.com'
)