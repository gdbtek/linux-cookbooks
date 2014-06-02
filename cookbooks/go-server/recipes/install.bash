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

    local i=0

    for ((i = 0; i <= ${numberOfAgent}; i++))
    do
        if [[ ${i} -eq 0 ]]
        then
            local agentFolderName='agent'
        else
            local agentFolderName="agent-${i}"
        fi

        mkdir -p "${agentInstallFolder}/${agentFolderName}" &&
        ln -s "${agentInstallFolder}/${agentFolderName}" "/var/lib/go-${agentFolderName}"
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

    # Clean Up

    rm -f "${serverPackageFile}" "${agentPackageFile}"
}

function configUpstart()
{
    local i=1

    for ((i = 1; i <= ${numberOfAgent}; i++))
    do
        local agentFolder="/var/lib/go-agent-${i}"

        if [[ -d "${agentFolder}" ]]
        then
            local upstartConfigData=(
                '__AGENT_NUMBER__' "${i}"
                '__AGENT_FOLDER__' "${agentFolder}"
                '__UID__' 'go'
                '__GID__' 'go'
            )

            createFileFromTemplate "${appPath}/../files/upstart/go-agent.conf" "/etc/init/go-agent-${i}.conf" "${upstartConfigData[@]}"
        else
            error "ERROR: directory '${agentFolder}' not found!"
        fi
    done
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

    local i=1

    for ((i = 1; i <= ${numberOfAgent}; i++))
    do
        start "go-agent-${i}"
    done
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    checkRequireDistributor

    header 'INSTALLING GO-SERVER'

    checkRequireRootUser
    checkRequirePort '8153' '8154'

    installDependencies
    install
    configUpstart
    startServer
    startAgents
    installCleanUp

    displayOpenPorts
}

main "${@}"
