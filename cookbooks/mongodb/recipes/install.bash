#!/bin/bash

function install()
{
    # Clean Up

    rm -rf "${installFolder}"
    mkdir -p "${installFolder}" "${installDataFolder}"

    # Install

    curl -L "${downloadURL}" | tar xz --strip 1 -C "${installFolder}"
    find "${installFolder}" -maxdepth 1 -type f -exec rm -f {} \;

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${installFolder}")

    createFileFromTemplate "${appPath}/../files/profile/mongodb.sh" '/etc/profile.d/mongodb.sh' "${profileConfigData[@]}"

    # Config Upstart

    local upstartConfigData=(
        '__INSTALL_FOLDER__' "${installFolder}"
        '__INSTALL_DATA_FOLDER__' "${installDataFolder}"
        '__PORT__' "${port}"
    )

    createFileFromTemplate "${appPath}/../files/upstart/mongodb.conf" "/etc/init/${serviceName}.conf" "${upstartConfigData[@]}"

    # Start

    start "${serviceName}"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    header 'INSTALLING MONGODB'

    checkRequireRootUser
    checkPortRequirement "${port}"

    install

    displayOpenPorts
}

main "${@}"
