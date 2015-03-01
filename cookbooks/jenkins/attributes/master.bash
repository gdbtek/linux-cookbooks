#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../groovy/attributes/default.bash"
source "$(dirname "${BASH_SOURCE[0]}")/../../tomcat/attributes/default.bash"

export jenkinsDownloadURL='http://mirrors.jenkins-ci.org/war/latest/jenkins.war'
export jenkinsUpdateCenterURL='http://updates.jenkins-ci.org/update-center.json'

export jenkinsInstallFolder='/opt/jenkins'

export jenkinsGroovyInstallFolder="${groovyInstallFolder}"

export jenkinsTomcatInstallFolder="${tomcatInstallFolder}"
export jenkinsTomcatHTTPPort="${tomcatHTTPPort}"

export jenkinsUserName="${tomcatUserName}"
export jenkinsGroupName="${tomcatGroupName}"

export jenkinsUpdateAllPlugins='true'

export jenkinsInstallPlugins=(
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