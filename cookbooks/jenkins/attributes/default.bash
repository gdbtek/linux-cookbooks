#!/bin/bash -e

source "$(dirname "${0}")/../../tomcat/attributes/default.bash"

jenkinsDownloadURL='http://mirrors.jenkins-ci.org/war/latest/jenkins.war'

jenkinsTomcatFolder="${tomcatInstallFolder}"

jenkinsUserName="${tomcatUserName}"
jenkinsGroupName="${tomcatGroupName}"