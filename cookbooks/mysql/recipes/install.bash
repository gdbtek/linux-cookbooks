#!/bin/bash

function installDependencies()
{
    apt-get update

    apt-get install -y curl
    apt-get install -y libaio-dev
}

function install()
{
    rm -rf "${installFolder}"
    rm -f "/usr/local/$(getFileName "${installFolder}")"
    mkdir -p "${installFolder}"

    curl -L "${downloadURL}" | tar xz --strip 1 -C "${installFolder}"

    addSystemUser "${user}"
    ln -s "${installFolder}" "/usr/local/$(getFileName "${installFolder}")"
    chown -R "${user}" "${installFolder}"
    chgrp -R "${user}" "${installFolder}"
    "${installFolder}/scripts/mysql_install_db" --user="${user}"
    chown -R "$(whoami)" "${installFolder}"
    chown -R "${user}" "${installFolder}/data"
    cp "${installFolder}/support-files/mysql.server" "${etcInitFile}"
    service "$(getFileName "${installFolder}")" start

    echo "export PATH=\"${installBinFolder}:\$PATH\"" > "${etcProfileFile}"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    header 'INSTALLING MYSQL'

    checkRequireRootUser
    checkPortRequirement "${requirePorts[@]}"

    installDependencies
    install

    sleep 3
    displayOpenPorts
}

main "${@}"
