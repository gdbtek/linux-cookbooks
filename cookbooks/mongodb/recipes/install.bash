#!/bin/bash -e

function install()
{
    # Clean Up

    initializeFolder "${mongodbInstallFolder:?}"
    initializeFolder "${mongodbInstallDataFolder:?}"

    # Install

    unzipRemoteFile "${mongodbDownloadURL:?}" "${mongodbInstallFolder}"
    find "${mongodbInstallFolder}" -maxdepth 1 -type f -delete

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${mongodbInstallFolder}")

    createFileFromTemplate "${appPath}/../templates/default/mongodb.sh.profile" '/etc/profile.d/mongodb.sh' "${profileConfigData[@]}"

    # Config Upstart

    local -r upstartConfigData=(
        '__INSTALL_FOLDER__' "${mongodbInstallFolder}"
        '__INSTALL_DATA_FOLDER__' "${mongodbInstallDataFolder}"
        '__USER_NAME__' "${mongodbUserName}"
        '__GROUP_NAME__' "${mongodbGroupName}"
        '__PORT__' "${mongodbPort}"
    )

    createFileFromTemplate "${appPath}/../templates/default/mongodb.conf.upstart" "/etc/init/${mongodbServiceName:?}.conf" "${upstartConfigData[@]}"
    chown -R "$(whoami):$(whoami)" "${mongodbInstallFolder}"

    # Start

    addUser "${mongodbUserName}" "${mongodbGroupName}" 'false' 'true' 'false'
    chown -R "${mongodbUserName}:${mongodbGroupName}" "${mongodbInstallFolder}"
    start "${mongodbServiceName}"

    # Display Version

    info "\n$("${mongodbInstallFolder}/bin/mongo" --version)"
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING MONGODB'

    checkRequirePort "${mongodbPort}"

    install
    installCleanUp

    displayOpenPorts
}

main "${@}"