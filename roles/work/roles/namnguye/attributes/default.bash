#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../../../../cookbooks/node-js/attributes/default.bash"

export NAMNGUYE_GIT_USER_NAME='Nam Nguyen'
export NAMNGUYE_GIT_USER_EMAIL='namnguye@adobe.com'

export NAMNGUYE_NODE_JS_INSTALL_FOLDER_PATH="${NODE_JS_INSTALL_FOLDER_PATH}"
export NAMNGUYE_NODE_JS_VERSION='latest'

export CLOUD_USERS=(
    'nam'
    'namnguye'
    'root'
)