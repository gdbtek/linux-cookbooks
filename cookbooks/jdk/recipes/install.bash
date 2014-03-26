#!/bin/bash

function install()
{
    rm -rf "${installFolder}"
    mkdir -p "${installFolder}"

    curl -L "${downloadURL}" | tar xz --strip 1 -C "${tempFolder}"

    echo "export PATH=\"${installFolder}/sbin:\$PATH\"" > "${etcProfileFile}"
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
