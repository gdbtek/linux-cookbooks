#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../jdk/attributes/default.bash"

export WILD_FLY_JDK_INSTALL_FOLDER_PATH="${JDK_INSTALL_FOLDER_PATH}"

export WILD_FLY_DOWNLOAD_URL='http://download.jboss.org/wildfly/15.0.1.Final/wildfly-15.0.1.Final.tar.gz'
export WILD_FLY_INSTALL_FOLDER_PATH='/opt/wild-fly'

export WILD_FLY_USER_NAME='wild-fly'
export WILD_FLY_GROUP_NAME='wild-fly'

export WILD_FLY_MANAGEMENT_USER='wild-fly'
export WILD_FLY_MANAGEMENT_PASSWORD='wild-fly'

export WILD_FLY_SERVICE_NAME='wild-fly'

export WILD_FLY_APPLICATION_BIND_ADDRESS='0.0.0.0'
export WILD_FLY_MANAGEMENT_BIND_ADDRESS='localhost'