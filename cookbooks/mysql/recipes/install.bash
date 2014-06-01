#!/bin/bash

function installDependencies()
{
    apt-get update

    apt-get install -y libaio-dev
    apt-get install -y sysv-rc-conf
}

function install()
{
    # Clean Up

    rm -rf "${installFolder}" "/usr/local/$(getFileName "${installFolder}")"
    mkdir -p "${installFolder}"

    # Install

    local currentPath="$(pwd)"

    unzipRemoteFile "${downloadURL}" "${installFolder}"
    addSystemUser "${uid}" "${gid}"
    ln -s "${installFolder}" "/usr/local/$(getFileName "${installFolder}")"
    chown -R "${uid}":"${gid}" "${installFolder}"
    cd "${installFolder}"
    "${installFolder}/scripts/mysql_install_db" --user="${uid}"
    chown -R "$(whoami)" "${installFolder}"
    chown -R "${uid}" "${installFolder}/data"
    cd "${currentPath}"

    # Config Server

    local serverConfigData=('__PORT__' "${port}")

    createFileFromTemplate "${appPath}/../files/conf/my.cnf" "${installFolder}/my.cnf" "${serverConfigData[@]}"

    # Config Service

    cp "${installFolder}/support-files/mysql.server" "/etc/init.d/${serviceName}"
    sysv-rc-conf --level 2345 "${serviceName}" on

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${installFolder}")

    createFileFromTemplate "${appPath}/../files/profile/mysql.sh" '/etc/profile.d/mysql.sh' "${profileConfigData[@]}"

    # Start

    service "${serviceName}" start
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    header 'INSTALLING MYSQL'

    checkRequireRootUser
    checkRequirePort "${port}"

    installDependencies
    install
    installCleanUp

    displayOpenPorts
}

main "${@}"
