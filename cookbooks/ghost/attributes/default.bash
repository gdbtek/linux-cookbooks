#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../node-js/attributes/default.bash"

export GHOST_DOWNLOAD_URL='https://ghost.org/zip/ghost-latest.zip'

export GHOST_INSTALL_FOLDER_PATH='/opt/ghost'
export GHOST_NODE_JS_INSTALL_FOLDER_PATH="${NODE_JS_INSTALL_FOLDER_PATH}"
export GHOST_NODE_JS_VERSION='6.9.4'

export GHOST_SERVICE_NAME='ghost'

export GHOST_USER_NAME='ghost'
export GHOST_GROUP_NAME='ghost'

export GHOST_PRODUCTION_URL='http://127.0.0.1'
export GHOST_PRODUCTION_HOST='127.0.0.1'
export GHOST_PRODUCTION_PORT='2368'

export GHOST_DEVELOPMENT_URL='http://127.0.0.1'
export GHOST_DEVELOPMENT_HOST='127.0.0.1'
export GHOST_DEVELOPMENT_PORT='2368'

export GHOST_TESTING_URL='http://127.0.0.1:2369'
export GHOST_TESTING_HOST='127.0.0.1'
export GHOST_TESTING_PORT='2369'

export GHOST_ENVIRONMENT='production'
# export GHOST_ENVIRONMENT='development'