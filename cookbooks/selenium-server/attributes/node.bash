#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../jdk/attributes/default.bash"

export SELENIUM_SERVER_DOWNLOAD_URL='http://selenium-release.storage.googleapis.com/3.141/selenium-server-standalone-3.141.59.jar'

export SELENIUM_SERVER_INSTALL_FOLDER_PATH='/opt/selenium-server/node'
export SELENIUM_SERVER_JDK_INSTALL_FOLDER_PATH="${JDK_INSTALL_FOLDER_PATH}"

export SELENIUM_SERVER_SERVICE_NAME='selenium-server-node'

export SELENIUM_SERVER_USER_NAME='selenium'
export SELENIUM_SERVER_GROUP_NAME='selenium'

export SELENIUM_SERVER_PORT='5555'
export SELENIUM_SERVER_HUB_PORT='4444'
export SELENIUM_SERVER_HUB_HOST='127.0.0.1'