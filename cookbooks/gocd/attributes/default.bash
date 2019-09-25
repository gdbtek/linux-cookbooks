#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../jdk/attributes/default.bash"

export GOCD_AGENT_DOWNLOAD_URL='https://download.gocd.org/binaries/19.7.0-9567/generic/go-agent-19.7.0-9567.zip'
export GOCD_SERVER_DOWNLOAD_URL='https://download.gocd.org/binaries/19.7.0-9567/generic/go-server-19.7.0-9567.zip'

export GOCD_AGENT_INSTALL_FOLDER_PATH='/opt/gocd/agents/agent'
export GOCD_JDK_INSTALL_FOLDER_PATH="${JDK_INSTALL_FOLDER_PATH}"
export GOCD_SERVER_INSTALL_FOLDER_PATH='/opt/gocd/server'

export GOCD_AGENT_SERVICE_NAME='gocd-agent'
export GOCD_SERVER_SERVICE_NAME='gocd-server'

export GOCD_GROUP_NAME='go'
export GOCD_USER_NAME='go'