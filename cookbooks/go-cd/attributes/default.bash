#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../jdk/attributes/default.bash"

export GO_CD_SERVER_DOWNLOAD_URL='https://download.gocd.org/binaries/18.6.0-6883/generic/go-server-18.6.0-6883.zip'
export GO_CD_AGENT_DOWNLOAD_URL='https://download.gocd.org/binaries/18.6.0-6883/generic/go-agent-18.6.0-6883.zip'

export GO_CD_SERVER_INSTALL_FOLDER_PATH='/opt/go-cd/server'
export GO_CD_AGENT_INSTALL_FOLDER_PATH='/opt/go-cd/agents/agent'
export GO_CD_JDK_INSTALL_FOLDER_PATH="${JDK_INSTALL_FOLDER_PATH}"

export GO_CD_SERVER_SERVICE_NAME='go-cd-server'
export GO_CD_AGENT_SERVICE_NAME='go-cd-agent'

export GO_CD_USER_NAME='go'
export GO_CD_GROUP_NAME='go'