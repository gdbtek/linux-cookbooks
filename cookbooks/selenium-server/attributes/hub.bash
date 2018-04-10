#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../jdk/attributes/default.bash"

export SELENIUM_SERVER_DOWNLOAD_URL='http://selenium-release.storage.googleapis.com/3.11/selenium-server-standalone-3.11.0.jar'

export SELENIUM_SERVER_INSTALL_FOLDER_PATH='/opt/selenium-server/hub'
export SELENIUM_SERVER_JDK_INSTALL_FOLDER_PATH="${JDK_INSTALL_FOLDER_PATH}"

export SELENIUM_SERVER_SERVICE_NAME='selenium-server-hub'

export SELENIUM_SERVER_USER_NAME='selenium'
export SELENIUM_SERVER_GROUP_NAME='selenium'

export SELENIUM_SERVER_PORT='4444'