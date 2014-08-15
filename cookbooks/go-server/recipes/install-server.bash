#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${jdkInstallFolder}" ]]
    then
        "${appPath}/../../jdk/recipes/install.bash"
    fi
}

function install()
{
    # Clean Up

    rm --force --recursive "${goserverServerInstallFolder}"
    mkdir --parents "${goserverServerInstallFolder}"

    # Install

    addgroup "${goserverGID}" >> /dev/null 2>&1
    useradd "${goserverUID}" --gid "${goserverGID}" --shell '/bin/bash' --create-home
    unzipRemoteFile "${goserverServerDownloadURL}" "${goserverServerInstallFolder}"

    local unzipFolderName="$(ls --directory ${goserverServerInstallFolder}/*/ 2> '/dev/null')"

    if [[ "$(isEmptyString "${unzipFolderName}")" = 'false' && "$(echo "${unzipFolderName}" | wc --lines)" = '1' ]]
    then
        if [[ "$(ls --almost-all "${unzipFolderName}")" != '' ]]
        then
            mv ${unzipFolderName}* "${goserverServerInstallFolder}" &&
            chown --recursive "${goserverUID}":"${goserverGID}" "${goserverServerInstallFolder}" &&
            rm --force --recursive "${unzipFolderName}"
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

    createFileFromTemplate "${appPath}/../templates/default/go-server.conf.upstart" "/etc/init/${goserverServerServiceName}.conf" "${upstartConfigData[@]}"
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
    source "${appPath}/../../jdk/attributes/default.bash" || exit 1

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING GO-SERVER (SERVER)'

    checkRequirePort '8153' '8154'

    installDependencies
    install
    configUpstart
    startServer
    installCleanUp

    displayOpenPorts
}

main "${@}"