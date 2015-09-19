#!/bin/bash -e

# shellcheck source=/dev/null
source "$(dirname "${BASH_SOURCE[0]}")/../../jdk/attributes/default.bash"

export JENKINS_WORKSPACE_FOLDER='/opt/jenkins'

export JENKINS_JDK_INSTALL_FOLDER="${JDK_INSTALL_FOLDER}"

export JENKINS_USER_NAME='root'
export JENKINS_GROUP_NAME='root'