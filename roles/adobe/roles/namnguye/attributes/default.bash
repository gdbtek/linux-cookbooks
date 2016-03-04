#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../../../../cookbooks/node-js/attributes/default.bash"

export NAMNGUYE_DISK='/dev/sdb'
export NAMNGUYE_MOUNT_ON='/opt'

export NAMNGUYE_GIT_USER_NAME='Nam Nguyen'
export NAMNGUYE_GIT_USER_EMAIL='namnguye@adobe.com'

export NAMNGUYE_NODE_JS_INSTALL_FOLDER="${NODE_JS_INSTALL_FOLDER}"
export NAMNGUYE_NODE_JS_VERSION='v0.10.43'