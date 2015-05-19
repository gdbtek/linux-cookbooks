#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../groovy/attributes/default.bash"
source "$(dirname "${BASH_SOURCE[0]}")/../../tomcat/attributes/default.bash"

export JENKINS_DOWNLOAD_URL='http://mirrors.jenkins-ci.org/war/latest/jenkins.war'
export JENKINS_UPDATE_CENTER_URL='http://updates.jenkins-ci.org/update-center.json'

export JENKINS_INSTALL_FOLDER='/opt/jenkins'

export JENKINS_GROOVY_INSTALL_FOLDER="${GROOVY_INSTALL_FOLDER}"

export JENKINS_TOMCAT_INSTALL_FOLDER="${tomcatInstallFolder:?}"
export JENKINS_TOMCAT_HTTP_PORT="${tomcatHTTPPort:?}"

export JENKINS_USER_NAME="${tomcatUserName:?}"
export JENKINS_GROUP_NAME="${tomcatGroupName:?}"

export JENKINS_UPDATE_ALL_PLUGINS='true'

export JENKINS_INSTALL_PLUGINS=(
    'ansicolor'
    'build-flow-plugin'
    'build-pipeline-plugin'
    'build-timeout'
    'build-token-root'
    'build-user-vars-plugin'
    'buildtriggerbadge'
    'cloudbees-folder'
    'copyartifact'
    'dashboard-view'
    'description-setter'
    'dynamicparameter'
    'email-ext'
    'embeddable-build-status'
    'envinject'
    'extended-choice-parameter'
    'git'
    'github'
    'github-oauth'
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
    'run-condition'
    'slack'
    'template-workflows'
    'testng-plugin'
    'thinBackup'
    'throttle-concurrents'
    'timestamper'
    'urltrigger'
    'ws-cleanup'
)