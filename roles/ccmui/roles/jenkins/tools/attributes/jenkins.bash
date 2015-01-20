#!/bin/bash -e

export user='root'

export master='jenkins.ccmui.adobe.com'

export slaves=(
    'jenkins-slave-1.ccmui.adobe.com'
    'jenkins-slave-2.ccmui.adobe.com'
    'jenkins-slave-3.ccmui.adobe.com'
)

export identityFile='/Volumes/Data/Data/Keys/ssh/adobe/it-cloud/private.key'