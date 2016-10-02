#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../../../../../../cookbooks/node-js/attributes/default.bash"

export CLOUD_JENKINS_GIT_USER_NAME='Nam Nguyen'
export CLOUD_JENKINS_GIT_USER_EMAIL='namnguye@adobe.com'

export CLOUD_JENKINS_NODE_JS_INSTALL_FOLDER="${NODE_JS_INSTALL_FOLDER}"
export CLOUD_JENKINS_NODE_JS_VERSION='v0.10.47'