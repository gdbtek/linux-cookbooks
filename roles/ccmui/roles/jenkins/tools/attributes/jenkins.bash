#!/bin/bash -e

user='root'

master='jenkins.ccmui.adobe.com'

slaves=(
    'jenkins-slave-1.ccmui.adobe.com'
    'jenkins-slave-2.ccmui.adobe.com'
    'jenkins-slave-3.ccmui.adobe.com'
    'jenkins-slave-4.ccmui.adobe.com'
)

identityFile='/Volumes/Data/Data/Keys/ssh/adobe/it-cloud/private.key'
