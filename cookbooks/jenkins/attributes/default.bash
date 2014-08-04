#!/bin/bash -e

source "$(dirname "${0}")/../../tomcat/attributes/default.bash" || exit 1

jenkinsDownloadURL='http://mirrors.jenkins-ci.org/war/latest/jenkins.war'

jenkinsTomcatFolder="${tomcatInstallFolder}"

jenkinsUID="${tomcatUID}"
jenkinsGID="${tomcatGID}"