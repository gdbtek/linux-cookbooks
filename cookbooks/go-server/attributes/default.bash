#!/bin/bash

goserverServerDownloadURL='http://download.go.cd/gocd/go-server-14.2.0-377.zip'
goserverAgentDownloadURL='http://download.go.cd/gocd/go-agent-14.2.0-377.zip'

goserverServerInstallFolder='/opt/go-server/server'
goserverAgentInstallFolder='/opt/go-server/agents/agent'

goserverServerServiceName='go-server'
goserverAgentServiceName='go-agent'

goserverUID='go'
goserverGID='go'