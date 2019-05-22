#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../groovy/attributes/default.bash"
source "$(dirname "${BASH_SOURCE[0]}")/../../tomcat/attributes/default.bash"

export JENKINS_DOWNLOAD_URL='http://mirrors.jenkins-ci.org/war/latest/jenkins.war'
export JENKINS_UPDATE_CENTER_URL='http://updates.jenkins-ci.org/update-center.json'

export JENKINS_INSTALL_FOLDER_PATH='/opt/jenkins'

export JENKINS_GROOVY_INSTALL_FOLDER_PATH="${GROOVY_INSTALL_FOLDER_PATH}"

export JENKINS_TOMCAT_INSTALL_FOLDER_PATH="${TOMCAT_INSTALL_FOLDER_PATH}"
export JENKINS_TOMCAT_HTTP_PORT="${TOMCAT_HTTP_PORT}"

export JENKINS_USER_NAME="${TOMCAT_USER_NAME}"
export JENKINS_GROUP_NAME="${TOMCAT_GROUP_NAME}"

export JENKINS_UPDATE_ALL_PLUGINS='true'

export JENKINS_INSTALL_PLUGINS=(
    'multiple-scms'
    'simple-theme-plugin'
)