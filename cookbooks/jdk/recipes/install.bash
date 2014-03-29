#!/bin/bash

function install()
{
    # Clean Up

    rm -rf "${installFolder}"
    mkdir -p "${installFolder}"

    # Install

    curl -L "${downloadURL}" | tar xz --strip 1 -C "${installFolder}"

    # Config Profile

    local newInstallFolder="$(escapeSearchPattern "${installFolder}")"

    sed "s@__INSTALL_FOLDER__@${newInstallFolder}@g" "${appPath}/../files/profile/jdk.sh" \
    > '/etc/profile.d/jdk.sh'
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    header 'INSTALLING JDK'

    checkRequireRootUser
    install
}

main "${@}"
