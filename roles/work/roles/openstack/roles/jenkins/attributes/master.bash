#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../../../../../../cookbooks/node-js/attributes/default.bash"

export OPENSTACK_JENKINS_GIT_USER_NAME='Nam Nguyen'
export OPENSTACK_JENKINS_GIT_USER_EMAIL='namnguye@adobe.com'

export OPENSTACK_JENKINS_NODE_JS_INSTALL_FOLDER="${NODE_JS_INSTALL_FOLDER}"
export OPENSTACK_JENKINS_NODE_JS_VERSION='v0.10.46'

export OPENSTACK_JENKINS_INSTALL_PLUGINS=(
    'datadog'
)