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
    'ansicolor'
    'build-pipeline-plugin'
    'build-timeout'
    'build-token-root'
    'build-user-vars-plugin'
    'buildtriggerbadge'
    'cloudbees-folder'
    'copyartifact'
    'dashboard-view'
    'description-setter'
    'email-ext'
    'embeddable-build-status'
    'envinject'
    'extended-choice-parameter'
    'git-changelog'
    'git'
    'github-oauth'
    'github'
    'gravatar'
    'greenballs'
    'htmlpublisher'
    'jenkins-multijob-plugin'
    'job-import-plugin'
    'jobConfigHistory'
    'ldapemail'
    'multiple-scms'
    'naginator'
    'Parameterized-Remote-Trigger'
    'parameterized-trigger'
    'project-inheritance'
    'publish-over-ssh'
    'rebuild'
    'run-condition'
    'slack'
    'ssh-slaves'
    'template-workflows'
    'testng-plugin'
    'thinBackup'
    'throttle-concurrents'
    'timestamper'
    'urltrigger'
    'workflow-aggregator'
    'ws-cleanup'
)