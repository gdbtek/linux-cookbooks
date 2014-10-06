#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../tomcat/attributes/default.bash"

jenkinsDownloadURL='http://mirrors.jenkins-ci.org/war/latest/jenkins.war'
jenkinsUpdateCenterURL='http://updates.jenkins-ci.org/update-center.json'

jenkinsInstallFolder='/opt/jenkins'

jenkinsTomcatInstallFolder="${tomcatInstallFolder}"
jenkinsTomcatHTTPPort="${tomcatHTTPPort}"

jenkinsUserName="${tomcatUserName}"
jenkinsGroupName="${tomcatGroupName}"

jenkinsUpdateAllPlugins='true'

jenkinsInstallPlugins=(
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
    'htmlpublisher'
    'jenkins-multijob-plugin'
    'job-import-plugin'
    'jobConfigHistory'
    'junit'
    'ldap'
    'ldapemail'
    'mailer'
    'matrix-auth'
    'matrix-project'
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