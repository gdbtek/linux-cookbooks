#!/bin/bash

function installDependencies()
{
    apt-get update

    apt-get install -y default-jre-headless
}

function install()
{
    # Clean Up

    rm -rf "${serverInstallFolder}" "${agentInstallFolder}"
    mkdir -p "${serverInstallFolder}" "${agentInstallFolder}"

    ln -s "${serverInstallFolder}" '/var/lib/go-server'

    for ((i = 0; i <= ${numberOfAgent}; i++))
    do
        if [[ ${i} -eq 0 ]]
        then
            local agentFolderName='go-agent'
        else
            local agentFolderName="go-agent-${i}"
        fi

        mkdir -p "${agentInstallFolder}/${agentFolderName}" &&
        ln -s "${agentInstallFolder}/${agentFolderName}" "/var/lib/${agentFolderName}"
    done

    # Install

    local serverPackageFile="$(getTemporaryFile "$(getFileExtension "${serverDownloadURL}")")"
    local agentPackageFile="$(getTemporaryFile "$(getFileExtension "${agentDownloadURL}")")"

    curl -L "${serverDownloadURL}" -o "${serverPackageFile}" &&
    dpkg -i "${serverPackageFile}" &&
    chown -R 'go:go' "${serverInstallFolder}"

    curl -L "${agentDownloadURL}" -o "${agentPackageFile}" &&
    dpkg -i "${agentPackageFile}" &&
    chown -R 'go:go' "${agentInstallFolder}"

    rm -f "${serverPackageFile}" "${agentPackageFile}"
}

function startServer()
{
    service go-server start
}

function startAgents()
{
    # Start Main Agent

    service go-agent start

    # Start Additional Agents

    local currentPath="$(pwd)"

    for ((i = 1; i <= ${numberOfAgent}; i++))
    do
        local agentFolder="/var/lib/go-agent-${i}"

        if [[ -d "/var/lib/go-agent-${i}" ]]
        then
            cd "${agentFolder}" &&
            su -c 'nohup java -jar /usr/share/go-agent/agent-bootstrapper.jar 127.0.0.1 &' go
        else
            error "ERROR: directory '${agentFolder}' not found!"
        fi
    done

    cd "${currentPath}"
}

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    header 'INSTALLING GO-SERVER'

    checkRequireRootUser
    checkPortRequirement "${serverPort}"
    checkPortRequirement "${agentPort}"

    installDependencies
    install
    startServer
    startAgents
    installCleanUp

    displayOpenPorts
}

main "${@}"
