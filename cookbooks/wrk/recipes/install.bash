#!/bin/bash

function install()
{
    # Clean Up

    rm -rf "${installFolder}"
    mkdir -p "${installFolder}/bin"

    # Install

    local currentPath="$(pwd)"
    local tempFolder="$(getTemporaryFolder)"

    git clone "${downloadURL}" "${tempFolder}"
    cd "${tempFolder}"
    make
    find "${tempFolder}" -maxdepth 1 -type f -perm -u+x -exec cp -f {} "${installFolder}/bin" \;
    rm -rf "${tempFolder}"
    cd "${currentPath}"

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${installFolder}")

    createFileFromTemplate "${appPath}/../files/profile/wrk.sh" '/etc/profile.d/wrk.sh' "${profileConfigData[@]}"
}

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    header 'INSTALLING WRK'

    install
    installCleanUp
}

main "${@}"
