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
    dpkg -i "${serverPackageFile}"

    curl -L "${agentDownloadURL}" -o "${agentPackageFile}" &&
    dpkg -i "${agentPackageFile}" &&
    service go-agent start

    rm -f "${serverPackageFile}" "${agentPackageFile}"

    # http://www.thoughtworks.com/products/docs/go/current/help/admin_install_multiple_agents.html

    local currentPath="$(pwd)"

    for ((i = 1; i <= numberOfAgent; i++))
    do
        local goAgentFolder="/var/lib/go-agent-${i}"

        mkdir -p "${goAgentFolder}" &&
        chown -R 'go:go' "${goAgentFolder}" &&
        cd "${goAgentFolder}" &&
        sudo -u go nohup java -jar /usr/share/go-agent/agent-bootstrapper.jar 127.0.0.1 &
    done

    cd "${currentPath}"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    header 'INSTALLING GO-SERVER'

    checkRequireRootUser
    checkPortRequirement "${port}"

    installDependencies
    install

    displayOpenPorts
}

main "${@}"
