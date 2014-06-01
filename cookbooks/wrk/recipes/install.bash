#!/bin/bash

function install()
{
    # Clean Up

    rm -rf "${installFolder}"
    mkdir -p "${installFolder}"

    # Install

    local currentPath="$(pwd)"
    local tempFolder="$(getTemporaryFolder)"

    git clone "${downloadURL}" "${tempFolder}"
    cd "${tempFolder}"
    make
    find "${tempFolder}" -type f -maxdepth 1 -perm -u+x -exec cp -f {} "${installFolder}" \;
    rm -rf "${tempFolder}"
    cd "${currentPath}"
}

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    header 'INSTALLING WRK'

    install
}

main "${@}"
