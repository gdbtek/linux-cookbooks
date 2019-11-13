#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../tomcat/attributes/default.bash"

export JENKINS_WORKSPACE_FOLDER='/opt/jenkins'

export JENKINS_USER_NAME="${TOMCAT_USER_NAME}"
export JENKINS_GROUP_NAME="${TOMCAT_GROUP_NAME}"