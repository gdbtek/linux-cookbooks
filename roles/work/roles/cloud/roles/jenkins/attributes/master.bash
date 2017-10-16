#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../../../../../../cookbooks/node-js/attributes/default.bash"
source "$(dirname "${BASH_SOURCE[0]}")/../../../../../../../cookbooks/tomcat/attributes/default.bash"

export CLOUD_JENKINS_GIT_USER_NAME='Nam Nguyen'
export CLOUD_JENKINS_GIT_USER_EMAIL='namnguye@adobe.com'

export CLOUD_JENKINS_NODE_JS_INSTALL_FOLDER_PATH="${NODE_JS_INSTALL_FOLDER_PATH}"
export CLOUD_JENKINS_NODE_JS_VERSION='v6.11.4'

export CLOUD_USERS=(
    'centos'
    'namnguye'
    'pxtops'
    'root'
    'ubuntu'
    "${TOMCAT_USER_NAME}"
)