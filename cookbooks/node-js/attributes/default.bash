#!/bin/bash -e

export NODE_JS_INSTALL_FOLDER_PATH='/opt/node-js'

# export NODE_JS_VERSION='v0.10.48'
export NODE_JS_VERSION='latest'

export NODE_JS_INSTALL_NPM_PACKAGES=(
    'npm'
    'bower'
    'grunt-cli'
)