#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${goserverJDKInstallFolder}" ]]
    then
        "${appPath}/../../jdk/recipes/install.bash" "${goserverJDKInstallFolder}"
    fi
}

function install()
{
    # Clean Up

    initializeFolder "${goserverServerInstallFolder}"

    # Install

    unzipRemoteFile "${goserverServerDownloadURL}" "${goserverServerInstallFolder}"

    local -r unzipFolder="$(find "${goserverServerInstallFolder}" -maxdepth 1 -xtype d 2> '/dev/null' | tail -1)"

    if [[ "$(isEmptyString "${unzipFolder}")" = 'true' || "$(wc -l <<< "${unzipFolder}")" != '1' ]]
    then
        fatal 'FATAL : multiple unzip folder names found'
    fi

    if [[ "$(ls -A "${unzipFolder}")" = '' ]]
    then
        fatal "FATAL : folder '${unzipFolder}' empty"
    fi

    # Move Folder

    local -r currentPath="$(pwd)"

    cd "${unzipFolder}"
    find '.' -maxdepth 1 -not -name '.' -exec mv '{}' "${goserverServerInstallFolder}" \;
    cd "${currentPath}"

    # Finalize

    addUser "${goserverUserName}" "${goserverGroupName}" 'true' 'false' 'true'
    chown -R "${goserverUserName}:${goserverGroupName}" "${goserverServerInstallFolder}"
    rm -f -r "${unzipFolder}"
}

function configUpstart()
{
    local -r upstartConfigData=(
        '__SERVER_INSTALL_FOLDER__' "${goserverServerInstallFolder}"
        '__GO_HOME_FOLDER__' "$(getUserHomeFolder "${goserverUserName}")"
        '__USER_NAME__' "${goserverUserName}"
        '__GROUP_NAME__' "${goserverGroupName}"
    )

    createFileFromTemplate "${appPath}/../templates/default/go-server.conf.upstart" "/etc/init/${goserverServerServiceName}.conf" "${upstartConfigData[@]}"
}

function startServer()
{
    start "${goserverServerServiceName}"
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

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