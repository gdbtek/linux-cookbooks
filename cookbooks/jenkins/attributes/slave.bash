#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../jdk/attributes/default.bash"

export JENKINS_WORKSPACE_FOLDER='/opt/jenkins'

export JENKINS_JDK_INSTALL_FOLDER_PATH="${JDK_INSTALL_FOLDER_PATH}"

export JENKINS_USER_NAME='root'
export JENKINS_GROUP_NAME='root'