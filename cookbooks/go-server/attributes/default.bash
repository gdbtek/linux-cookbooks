#!/bin/bash

serverDownloadURL='http://download01.thoughtworks.com/go/14.1.0/ga/go-server-14.1.0-18882.zip'
agentDownloadURL='http://download01.thoughtworks.com/go/14.1.0/ga/go-agent-14.1.0-18882.zip'

serverInstallFolder='/opt/go-server/server'
agentInstallFolder='/opt/go-server/agents/agent'

jdkFolder='/opt/jdk'

serverServiceName='go-server'
agentServiceName='go-agent'

uid='go'
gid='go'

numberOfAgents=1
