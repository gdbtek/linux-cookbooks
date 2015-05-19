#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../jdk/attributes/default.bash"

export GO_SERVER_SERVER_DOWNLOAD_URL='http://download.go.cd/gocd/go-server-15.1.0-1863.zip'
export GO_SERVER_AGENT_DOWNLOAD_URL='http://download.go.cd/gocd/go-agent-15.1.0-1863.zip'

export GO_SERVER_SERVER_INSTALL_FOLDER='/opt/go-server/server'
export GO_SERVER_AGENT_INSTALL_FOLDER='/opt/go-server/agents/agent'
export GO_SERVER_JDK_INSTALL_FOLDER="${JDK_INSTALL_FOLDER}"

export GO_SERVER_SERVER_SERVICE_NAME='go-server'
export GO_SERVER_AGENT_SERVICE_NAME='go-agent'

export GO_SERVER_USER_NAME='go'
export GO_SERVER_GROUP_NAME='go'