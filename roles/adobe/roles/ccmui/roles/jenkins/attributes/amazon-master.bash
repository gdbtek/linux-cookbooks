#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../../../../../../cookbooks/node-js/attributes/default.bash"

export CCMUI_JENKINS_DISK='/dev/xvdb'
export CCMUI_JENKINS_MOUNT_ON='/opt'

export CCMUI_JENKINS_NODE_JS_INSTALL_FOLDER="${NODE_JS_INSTALL_FOLDER}"
export CCMUI_JENKINS_NODE_JS_VERSION='v0.10.45'

export CCMUI_JENKINS_INSTALL_PLUGINS=()