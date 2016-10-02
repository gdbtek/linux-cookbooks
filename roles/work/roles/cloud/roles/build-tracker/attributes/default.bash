#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../../../../../../cookbooks/node-js/attributes/default.bash"

###########
# PREPARE #
###########

export CLOUD_GIT_USER_NAME='Nam Nguyen'
export CLOUD_GIT_USER_EMAIL='namnguye@adobe.com'

export CLOUD_NODE_JS_INSTALL_FOLDER="${NODE_JS_INSTALL_FOLDER}"
export CLOUD_NODE_JS_VERSION='v0.10.47'

###########
# INSTALL #
###########

export CLOUD_BUILD_TRACKER_INSTALL_FOLDER='/opt/build-tracker'

export CLOUD_BUILD_TRACKER_SERVICE_NAME='build-tracker'

export CLOUD_BUILD_TRACKER_USER_NAME='build-tracker'
export CLOUD_BUILD_TRACKER_GROUP_NAME='build-tracker'