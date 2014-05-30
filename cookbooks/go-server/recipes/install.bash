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
    chown -R 'go:go' "${serverInstallFolder}" &&
    service go-server start

    curl -L "${agentDownloadURL}" -o "${agentPackageFile}" &&
    dpkg -i "${agentPackageFile}" &&
    chown -R 'go:go' "${agentInstallFolder}" &&
    service go-agent start

    rm -f "${serverPackageFile}" "${agentPackageFile}"
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
    installCleanUp

    displayOpenPorts
}

main "${@}"
