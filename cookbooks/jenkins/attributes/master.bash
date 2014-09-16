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
    'credentials'
    'dashboard-view'
    'email-ext'
    'envinject'
    'external-monitor-job'
    'git'
    'github'
    'github-oauth'
    'gravatar'
    'greenballs'
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
    'run-condition'
    'slack'
    'ssh-credentials'
    'ssh-slaves'
    'template-workflows'
    'thinBackup'
    'urltrigger'
)