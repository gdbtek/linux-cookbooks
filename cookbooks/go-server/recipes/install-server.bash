#!/bin/bash

function install()
{
    # Clean Up

    rm -rf "${goserverServerInstallFolder}"
    mkdir -p "${goserverServerInstallFolder}"

    # Install

    addSystemUser "${goserverUID}" "${goserverGID}"
    unzipRemoteFile "${goserverServerDownloadURL}" "${goserverServerInstallFolder}"

    local unzipFolderName="$(ls -d ${goserverServerInstallFolder}/*/ 2> '/dev/null')"

    if [[ "$(isEmptyString "${unzipFolderName}")" = 'false' && "$(echo "${unzipFolderName}" | wc -l)" = '1' ]]
    then
        if [[ "$(ls -A "${unzipFolderName}")" != '' ]]
        then
            mv ${unzipFolderName}* "${goserverServerInstallFolder}" &&
            chown -R "${goserverUID}":"${goserverGID}" "${goserverServerInstallFolder}" &&
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
    local upstartConfigData=(
        '__SERVER_INSTALL_FOLDER__' "${goserverServerInstallFolder}"
        '__UID__' "${goserverUID}"
        '__GID__' "${goserverGID}"
    )

    createFileFromTemplate "${appPath}/../files/upstart/go-server.conf" "/etc/init/${goserverServerServiceName}.conf" "${upstartConfigData[@]}"
}

function startServer()
{
    start "${goserverServerServiceName}"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    checkRequireDistributor

    header 'INSTALLING GO-SERVER (SERVER)'

    checkRequireRootUser
    checkRequirePort '8153' '8154'

    install
    configUpstart
    startServer
    installCleanUp

    displayOpenPorts
}

main "${@}"