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
    'git'
    'Parameterized-Remote-Trigger'
    'parameterized-trigger'
    'slack'
)