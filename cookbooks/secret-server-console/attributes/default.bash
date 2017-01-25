#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../jdk/attributes/default.bash"

export SECRET_SERVER_CONSOLE_DOWNLOAD_URL='http://updates.thycotic.net/secretserver/javaapi/latestversion/secretserver-jconsole.jar'

export SECRET_SERVER_CONSOLE_INSTALL_FOLDER_PATH='/opt/secret-server-console'
export SECRET_SERVER_CONSOLE_JDK_INSTALL_FOLDER_PATH="${JDK_INSTALL_FOLDER_PATH}"