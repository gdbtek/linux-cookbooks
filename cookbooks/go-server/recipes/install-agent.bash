#!/bin/bash

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' ]]
    then
        "${appPath}/../../jdk/recipes/install.bash"
    fi
}

function install()
{
    # Clean Up

    rm -rf "${goserverAgentInstallFolder}"
    mkdir -p "${goserverAgentInstallFolder}"

    # Install

    addgroup "${goserverGID}" >> /dev/null 2>&1
    useradd "${goserverUID}" -g "${goserverGID}" -s '/bin/bash' -m
    unzipRemoteFile "${goserverAgentDownloadURL}" "${goserverAgentInstallFolder}"

    local unzipFolderName="$(ls -d ${goserverAgentInstallFolder}/*/ 2> '/dev/null')"

    if [[ "$(isEmptyString "${unzipFolderName}")" = 'false' && "$(echo "${unzipFolderName}" | wc -l)" = '1' ]]
    then
        if [[ "$(ls -A "${unzipFolderName}")" != '' ]]
        then
            mv ${unzipFolderName}* "${goserverAgentInstallFolder}" &&
            chown -R "${goserverUID}":"${goserverGID}" "${goserverAgentInstallFolder}" &&
            rm -rf "${unzipFolderName}"
        else
            fatal "FATAL: folder '${unzipFolderName}' is empty"
        fi
    else
        fatal 'FATAL: found multiple unzip folder name!'
    fi
}

function configUpstart()
{
    local serverHostname="${1}"

    if [[ "$(isEmptyString "${serverHostname}")" = 'true' ]]
    then
        serverHostname='127.0.0.1'
    fi

    local upstartConfigData=(
        '__AGENT_INSTALL_FOLDER__' "${goserverAgentInstallFolder}"
        '__SERVER_HOSTNAME__' "${serverHostname}"
        '__GO_HOME_FOLDER__' "$(getUserHomeFolder "${goserverUID}")"
        '__UID__' "${goserverUID}"
        '__GID__' "${goserverGID}"
    )

    createFileFromTemplate "${appPath}/../files/upstart/go-agent.conf" "/etc/init/${goserverAgentServiceName}.conf" "${upstartConfigData[@]}"
}

function startAgent()
{
    start "${goserverAgentServiceName}"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING GO-SERVER (AGENT)'

    installDependencies
    install
    configUpstart "${@}"
    startAgent
    installCleanUp
}

main "${@}"