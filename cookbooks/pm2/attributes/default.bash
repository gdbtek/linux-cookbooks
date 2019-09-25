#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../node/attributes/default.bash"

export PM2_NODE_INSTALL_FOLDER_PATH="${NODE_INSTALL_FOLDER_PATH}"
export PM2_NODE_VERSION='latest'

export PM2_USER_NAME='pm2'
export PM2_GROUP_NAME='pm2'