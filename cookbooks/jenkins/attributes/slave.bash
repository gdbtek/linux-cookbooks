#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../jdk/attributes/default.bash"
source "$(dirname "${BASH_SOURCE[0]}")/../../tomcat/attributes/default.bash"

export JENKINS_WORKSPACE_FOLDER='/opt/jenkins'

export JENKINS_JDK_INSTALL_FOLDER_PATH="${JDK_INSTALL_FOLDER_PATH}"

export JENKINS_USER_NAME="${TOMCAT_USER_NAME}"
export JENKINS_GROUP_NAME="${TOMCAT_GROUP_NAME}"