#!/bin/bash -e

function install()
{
    # Clean Up

    rm -f -r "${mongodbInstallFolder}"
    mkdir -p "${mongodbInstallFolder}" "${mongodbInstallDataFolder}"

    # Install

    unzipRemoteFile "${mongodbDownloadURL}" "${mongodbInstallFolder}"
    find "${mongodbInstallFolder}" -maxdepth 1 -type f -exec rm -f {} \;

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${mongodbInstallFolder}")

    createFileFromTemplate "${appPath}/../templates/default/mongodb.sh.profile" '/etc/profile.d/mongodb.sh' "${profileConfigData[@]}"

    # Config Upstart

    local upstartConfigData=(
        '__INSTALL_FOLDER__' "${mongodbInstallFolder}"
        '__INSTALL_DATA_FOLDER__' "${mongodbInstallDataFolder}"
        '__PORT__' "${mongodbPort}"
    )

    createFileFromTemplate "${appPath}/../templates/default/mongodb.conf.upstart" "/etc/init/${mongodbServiceName}.conf" "${upstartConfigData[@]}"
    chown --recursive "$(whoami)":"$(whoami)" "${mongodbInstallFolder}"

    # Start

    start "${mongodbServiceName}"

    # Display Version

    info "\n$("${mongodbInstallFolder}/bin/mongo" --version)"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash"
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