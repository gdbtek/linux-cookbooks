#!/bin/bash

function install()
{
    # Clean Up

    rm -rf "${agentInstallFolder}"
    mkdir -p "${agentInstallFolder}"

    # Install

    addSystemUser "${uid}" "${gid}"
    unzipRemoteFile "${agentDownloadURL}" "${agentInstallFolder}"

    local unzipFolderName="$(ls -d ${agentInstallFolder}/*/ 2> '/dev/null')"

    if [[ "$(isEmptyString "${unzipFolderName}")" = 'false' && "$(echo "${unzipFolderName}" | wc -l)" = '1' ]]
    then
        if [[ "$(ls -A "${unzipFolderName}")" != '' ]]
        then
            mv ${unzipFolderName}* "${agentInstallFolder}" &&
            chown -R "${uid}":"${gid}" "${agentInstallFolder}" &&
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
        '__AGENT_INSTALL_FOLDER__' "${agentInstallFolder}"
        '__SERVER_HOSTNAME__' "${serverHostname}"
        '__GO_HOME_FOLDER__' "$(eval "echo ~${uid}")"
        '__UID__' "${uid}"
        '__GID__' "${gid}"
    )

    createFileFromTemplate "${appPath}/../files/upstart/go-agent.conf" "/etc/init/${agentServiceName}.conf" "${upstartConfigData[@]}"
}

function startAgent()
{
    start "${agentServiceName}"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    checkRequireDistributor

    header 'INSTALLING GO-SERVER (AGENT)'

    checkRequireRootUser

    install
    configUpstart "${@}"
    startAgent
    installCleanUp
}

main "${@}"
