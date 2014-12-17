#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../jdk/attributes/default.bash"

goserverServerDownloadURL='http://download.go.cd/gocd/go-server-14.4.0-1356.zip'
goserverAgentDownloadURL='http://download.go.cd/gocd/go-agent-14.4.0-1356.zip'

goserverServerInstallFolder='/opt/go-server/server'
goserverAgentInstallFolder='/opt/go-server/agents/agent'
goserverJDKInstallFolder="${jdkInstallFolder}"

goserverServerServiceName='go-server'
goserverAgentServiceName='go-agent'

goserverUserName='go'
goserverGroupName='go'