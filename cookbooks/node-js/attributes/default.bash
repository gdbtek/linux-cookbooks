#!/bin/bash -e

export NODE_JS_INSTALL_FOLDER_PATH='/opt/node-js'

# export NODE_JS_VERSION='v8.11.1'
export NODE_JS_VERSION='latest'

export NODE_JS_INSTALL_NPM_PACKAGES=(
    'npm@latest'
    'bower@latest'
    'grunt-cli@latest'
)