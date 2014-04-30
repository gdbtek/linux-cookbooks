#!/bin/bash

function start()
{
    local currentPath="$(pwd)"

    for ((i = 1; i <= numberOfAgent; i++))
    do
        local goAgentFolder="/var/lib/go-agent-${i}"

        if [[ -d "/var/lib/go-agent-${i}" ]]
        then
            cd "${goAgentFolder}" &&
            nohup java -jar /usr/share/go-agent/agent-bootstrapper.jar 127.0.0.1 &
        else
            error "ERROR: directory '${goAgentFolder}' not found!"
        fi
    done

    cd "${currentPath}"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    header 'STARTING GO-AGENT'

    checkRequireUser 'go'

    start

    displayOpenPorts
}

main "${@}"
