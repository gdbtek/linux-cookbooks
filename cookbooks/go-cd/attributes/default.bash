#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../jdk/attributes/default.bash"

export GO_CD_SERVER_DOWNLOAD_URL='https://download.go.cd/binaries/16.11.0-4185/generic/go-server-16.11.0-4185.zip'
export GO_CD_AGENT_DOWNLOAD_URL='https://download.go.cd/binaries/16.11.0-4185/generic/go-agent-16.11.0-4185.zip'

export GO_CD_SERVER_INSTALL_FOLDER='/opt/go-cd/server'
export GO_CD_AGENT_INSTALL_FOLDER='/opt/go-cd/agents/agent'
export GO_CD_JDK_INSTALL_FOLDER="${JDK_INSTALL_FOLDER}"

export GO_CD_SERVER_SERVICE_NAME='go-cd-server'
export GO_CD_AGENT_SERVICE_NAME='go-cd-agent'

export GO_CD_USER_NAME='go'
export GO_CD_GROUP_NAME='go'