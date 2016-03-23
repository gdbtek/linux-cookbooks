#!/bin/bash -e

export SSH_LOGIN='root'
export SSH_IDENTITY_FILE='/Volumes/Data/Data/Keys/ssh/adobe/it-cloud/private.key'

export MASTER_SERVERS=(
    'qe-jenkins.ccmui.adobe.com'
)

export SLAVE_SERVERS=(
    'qe-jenkins-slave-1.ccmui.adobe.com'
    'qe-jenkins-slave-2.ccmui.adobe.com'
    'qe-jenkins-slave-3.ccmui.adobe.com'
    'qe-jenkins-slave-4.ccmui.adobe.com'
    'qe-jenkins-slave-5.ccmui.adobe.com'
)