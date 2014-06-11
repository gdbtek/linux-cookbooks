#!/bin/bash

function installDependencies()
{
    runAptGetUpdate

    installPackage 'default-jre-headless'
}

function install()
{
    # Clean Up

    rm -rf "${agentInstallFolder}"
    mkdir -p "${agentInstallFolder}"

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

    local agentPackageFile="$(getTemporaryFile "$(getFileExtension "${agentDownloadURL}")")"

    curl -L "${agentDownloadURL}" -o "${agentPackageFile}" &&
    dpkg -i "${agentPackageFile}" &&
    chown -R 'go:go' "${agentInstallFolder}"

    # Clean Up

    rm -f "${agentPackageFile}"
}

function configUpstart()
{
    local i=1

    for ((i = 1; i <= ${numberOfAgent}; i++))
    do
        local agentFolder="/var/lib/go-agent-${i}"

        if [[ "$(isEmptyString "${agentFolder}")" = 'false' && -d "${agentFolder}" ]]
        then
            local upstartConfigData=(
                '__AGENT_NUMBER__' "${i}"
                '__AGENT_FOLDER__' "${agentFolder}"
                '__UID__' 'go'
                '__GID__' 'go'
            )

            createFileFromTemplate "${appPath}/../files/upstart/go-agent.conf" "/etc/init/go-agent-${i}.conf" "${upstartConfigData[@]}"
        else
            error "ERROR: directory '${agentFolder}' not found or undefined!"
        fi
    done
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

    header 'INSTALLING GO-SERVER (AGENT)'

    checkRequireRootUser

    installDependencies
    install
    configUpstart
    startAgents
    installCleanUp
}

main "${@}"
