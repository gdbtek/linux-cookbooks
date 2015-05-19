#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../jdk/attributes/default.bash"

export jenkinsWorkspaceFolder='/opt/jenkins'

export jenkinsJDKInstallFolder="${JDK_INSTALL_FOLDER}"

export JENKINS_USER_NAME='root'
export JENKINS_GROUP_NAME='root'