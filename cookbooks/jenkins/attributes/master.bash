#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../tomcat/attributes/default.bash"

export jenkinsDownloadURL='http://mirrors.jenkins-ci.org/war/latest/jenkins.war'
export jenkinsUpdateCenterURL='http://updates.jenkins-ci.org/update-center.json'

export jenkinsInstallFolder='/opt/jenkins'

export jenkinsTomcatInstallFolder="${tomcatInstallFolder}"
export jenkinsTomcatHTTPPort="${tomcatHTTPPort}"

export jenkinsUserName="${tomcatUserName}"
export jenkinsGroupName="${tomcatGroupName}"

export jenkinsUpdateAllPlugins='true'

export jenkinsInstallPlugins=(
    'ansicolor'
    'ant'
    'build-flow-plugin'
    'build-pipeline-plugin'
    'build-timeout'
    'build-token-root'
    'build-user-vars-plugin'
    'buildtriggerbadge'
    'cloudbees-folder'
    'copyartifact'
    'credentials'
    'dashboard-view'
    'description-setter'
    'disk-usage'
    'email-ext'
    'embeddable-build-status'
    'envinject'
    'external-monitor-job'
    'git'
    'github'
    'github-oauth'
    'gravatar'
    'greenballs'
    'hipchat'
    'htmlpublisher'
    'jenkins-multijob-plugin'
    'job-import-plugin'
    'jobConfigHistory'
    'ldap'
    'ldapemail'
    'mailer'
    'maven-plugin'
    'Parameterized-Remote-Trigger'
    'parameterized-trigger'
    'project-inheritance'
    'publish-over-ssh'
    'run-condition'
    'slack'
    'ssh'
    'ssh-credentials'
    'ssh-slaves'
    'template-workflows'
    'testng-plugin'
    'thinBackup'
    'throttle-concurrents'
    'timestamper'
    'urltrigger'
    'ws-cleanup'
)