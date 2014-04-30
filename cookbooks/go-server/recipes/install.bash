#!/bin/bash

function installDependencies()
{
    apt-get update

    apt-get install -y default-jre-headless
}

function install()
{
    # Install

    local serverPackageFile="$(getTemporaryFile "$(getFileExtension "${serverDownloadURL}")")"
    local agentPackageFile="$(getTemporaryFile "$(getFileExtension "${agentDownloadURL}")")"

    curl -L "${serverDownloadURL}" -o "${serverPackageFile}" &&
    dpkg -i "${serverPackageFile}" &&
    service go-server start

    curl -L "${agentDownloadURL}" -o "${agentPackageFile}" &&
    dpkg -i "${agentPackageFile}" &&
    service go-agent start

    rm -f "${serverPackageFile}" "${agentPackageFile}"

    # Only Create Go-Agent Folder Structure

    for ((i = 1; i <= numberOfAgent; i++))
    do
        local goAgentFolder="/var/lib/go-agent-${i}"

        mkdir -p "${goAgentFolder}" &&
        chown -R 'go:go' "${goAgentFolder}"
    done
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    header 'INSTALLING GO-SERVER'

    checkRequireRootUser
    checkPortRequirement "${serverPort}"
    checkPortRequirement "${agentPort}"

    installDependencies
    install

    displayOpenPorts
}

main "${@}"
