#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../../../../../../cookbooks/node-js/attributes/default.bash"

export CCMUI_OPS_DISK='/dev/sdb'
export CCMUI_OPS_MOUNT_ON='/opt'

export CCMUI_OPS_GIT_USER_NAME='Nam Nguyen'
export CCMUI_OPS_GIT_USER_EMAIL='namnguye@adobe.com'

export CCMUI_OPS_NODE_JS_INSTALL_FOLDER="${NODE_JS_INSTALL_FOLDER}"
export CCMUI_OPS_NODE_JS_VERSION='v0.10.39'