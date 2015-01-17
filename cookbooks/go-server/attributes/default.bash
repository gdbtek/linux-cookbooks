#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../jdk/attributes/default.bash"

export goserverServerDownloadURL='http://download.go.cd/gocd/go-server-14.4.0-1356.zip'
export goserverAgentDownloadURL='http://download.go.cd/gocd/go-agent-14.4.0-1356.zip'

export goserverServerInstallFolder='/opt/go-server/server'
export goserverAgentInstallFolder='/opt/go-server/agents/agent'
export goserverJDKInstallFolder="${jdkInstallFolder}"

export goserverServerServiceName='go-server'
export goserverAgentServiceName='go-agent'

export goserverUserName='go'
export goserverGroupName='go'