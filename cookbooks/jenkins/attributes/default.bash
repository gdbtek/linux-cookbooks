#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../tomcat/attributes/default.bash"

jenkinsDownloadURL='http://mirrors.jenkins-ci.org/war/latest/jenkins.war'
jenkinsUpdateCenterURL='http://updates.jenkins-ci.org/update-center.json'

jenkinsHomeFolder='/opt/jenkins'
jenkinsTomcatFolder="${tomcatInstallFolder}"
jenkinsTomcatHTTPPort="${tomcatHTTPPort}"

jenkinsUserName="${tomcatUserName}"
jenkinsGroupName="${tomcatGroupName}"

jenkinsUpdateAllPlugins='true'

jenkinsInstallPlugins=(
    'git'
    'slack'
)