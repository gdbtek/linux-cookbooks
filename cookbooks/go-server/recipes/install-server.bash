#!/bin/bash

function install()
{
    # Clean Up

    rm -rf "${serverInstallFolder}"
    mkdir -p "${serverInstallFolder}"

    # Install

    addSystemUser "${uid}" "${gid}"
    unzipRemoteFile "${serverDownloadURL}" "${serverInstallFolder}"

    local unzipFolderName="$(ls -d ${serverInstallFolder}/*/ 2> '/dev/null')"

    if [[ "$(isEmptyString "${unzipFolderName}")" = 'false' && "$(echo "${unzipFolderName}" | wc -l)" = '1' ]]
    then
        if [[ "$(ls -A "${unzipFolderName}")" != '' ]]
        then
            mv ${unzipFolderName}* "${serverInstallFolder}" &&
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
        '__SERVER_INSTALL_FOLDER__' "${serverInstallFolder}"
        '__JDK_FOLDER__' "${jdkFolder}"
        '__UID__' "${uid}"
        '__GID__' "${gid}"
    )

    createFileFromTemplate "${appPath}/../files/upstart/go-server.conf" "/etc/init/${serverServiceName}.conf" "${upstartConfigData[@]}"
}

function startServer()
{
    start "${serverServiceName}"
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
