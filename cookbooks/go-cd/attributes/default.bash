#!/bin/bash -e

# shellcheck source=/dev/null
source "$(dirname "${BASH_SOURCE[0]}")/../../jdk/attributes/default.bash"

export GO_CD_SERVER_DOWNLOAD_URL='http://download.go.cd/gocd/go-server-15.2.0-2248.zip'
export GO_CD_AGENT_DOWNLOAD_URL='http://download.go.cd/gocd/go-agent-15.2.0-2248.zip'

export GO_CD_SERVER_INSTALL_FOLDER='/opt/go-cd/server'
export GO_CD_AGENT_INSTALL_FOLDER='/opt/go-cd/agents/agent'
export GO_CD_JDK_INSTALL_FOLDER="${JDK_INSTALL_FOLDER}"

export GO_CD_SERVER_SERVICE_NAME='go-cd-server'
export GO_CD_AGENT_SERVICE_NAME='go-cd-agent'

export GO_CD_USER_NAME='go'
export GO_CD_GROUP_NAME='go'