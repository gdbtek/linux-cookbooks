#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../../../../../../cookbooks/node-js/attributes/default.bash"

export CLOUD_JENKINS_GIT_USER_NAME='Nam Nguyen'
export CLOUD_JENKINS_GIT_USER_EMAIL='namnguye@adobe.com'

export CLOUD_JENKINS_NODE_JS_INSTALL_FOLDER_PATH="${NODE_JS_INSTALL_FOLDER_PATH}"
export CLOUD_JENKINS_NODE_JS_VERSION='v0.10.48'

export CLOUD_JENKINS_INSTALL_PLUGINS=(
    'datadog'
)

export CLOUD_USERS=(
    'centos'
    'ecxops'
    'namnguye'
    'root'
    'ubuntu'
)