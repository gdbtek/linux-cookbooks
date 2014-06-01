#!/bin/bash

function install()
{
    # Clean Up

    rm -rf "${installFolder}"
    mkdir -p "${installFolder}/bin"

    # Install

    local currentPath="$(pwd)"
    local tempFolder="$(getTemporaryFolder)"

    curl -L "${downloadURL}" | tar x --strip 1 -C "${tempFolder}"
    cd "${tempFolder}"
    "${tempFolder}/configure" --prefix="${installFolder}"
    make
    make install
    rm -rf "${tempFolder}"
    cd "${currentPath}"

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${installFolder}")

    createFileFromTemplate "${appPath}/../files/profile/siege.sh" '/etc/profile.d/siege.sh' "${profileConfigData[@]}"
}

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    header 'INSTALLING SIEGE'

    install
    installCleanUp
}

main "${@}"
