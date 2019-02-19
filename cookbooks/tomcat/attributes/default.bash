#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../jdk/attributes/default.bash"

export TOMCAT_DOWNLOAD_URL='http://www-us.apache.org/dist/tomcat/tomcat-9/v9.0.16/bin/apache-tomcat-9.0.16.tar.gz'

export TOMCAT_INSTALL_FOLDER_PATH='/opt/tomcat'
export TOMCAT_JDK_INSTALL_FOLDER_PATH="${JDK_INSTALL_FOLDER_PATH}"

export TOMCAT_SERVICE_NAME='tomcat'

export TOMCAT_USER_NAME='tomcat'
export TOMCAT_GROUP_NAME='tomcat'

export TOMCAT_AJP_PORT='8009'
export TOMCAT_COMMAND_PORT='8005'
export TOMCAT_HTTP_PORT='8080'
export TOMCAT_HTTPS_PORT='8443'