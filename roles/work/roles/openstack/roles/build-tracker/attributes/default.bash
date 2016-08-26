#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../../../../../../cookbooks/node-js/attributes/default.bash"

###########
# PREPARE #
###########

export OPENSTACK_GIT_USER_NAME='Nam Nguyen'
export OPENSTACK_GIT_USER_EMAIL='namnguye@adobe.com'

export OPENSTACK_NODE_JS_INSTALL_FOLDER="${NODE_JS_INSTALL_FOLDER}"
export OPENSTACK_NODE_JS_VERSION='v0.10.46'

###########
# INSTALL #
###########

export OPENSTACK_BUILD_TRACKER_INSTALL_FOLDER='/opt/build-tracker'

export OPENSTACK_BUILD_TRACKER_SERVICE_NAME='build-tracker'

export OPENSTACK_BUILD_TRACKER_USER_NAME='build-tracker'
export OPENSTACK_BUILD_TRACKER_GROUP_NAME='build-tracker'