#!/bin/bash -e

export SSH_LOGIN='root'
export SSH_IDENTITY_FILE='/Volumes/Data/Data/Keys/ssh/adobe/it-cloud/private.key'

export MASTER_SERVERS=(
    'selenium.ccmui.adobe.com'
)

export SLAVE_SERVERS=()