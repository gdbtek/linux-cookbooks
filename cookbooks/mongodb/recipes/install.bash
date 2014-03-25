#!/bin/bash

function install()
{
    rm -rf "${installFolder}"
    mkdir -p "${installFolder}" "${installDataFolder}"

    curl -L "${downloadURL}" | tar xz --strip 1 -C "${installFolder}"
    find "${installFolder}" -maxdepth 1 -type f -exec rm -f {} \;

    echo "export PATH=\"${installFolder}/bin:\$PATH\"" > "${etcProfileFile}"
    cp -f "${appPath}/../files/upstart/mongodb.conf" "${etcInitFile}"

    start "$(getFileName "${etcInitFile}")"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    header 'INSTALLING MONGODB'

    checkRequireRootUser
    install
}

main "${@}"
