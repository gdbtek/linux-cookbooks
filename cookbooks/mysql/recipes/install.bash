#!/bin/bash

function installDependencies()
{
    runAptGetUpdate

    installAptGetPackages 'libaio-dev' 'sysv-rc-conf'
}

function install()
{
    # Clean Up

    rm -rf "${mysqlInstallFolder}" "/usr/local/$(getFileName "${mysqlInstallFolder}")"
    mkdir -p "${mysqlInstallFolder}"

    # Install

    local currentPath="$(pwd)"

    unzipRemoteFile "${mysqlDownloadURL}" "${mysqlInstallFolder}"
    addSystemUser "${mysqlUID}" "${mysqlGID}"
    ln -s "${mysqlInstallFolder}" "/usr/local/$(getFileName "${mysqlInstallFolder}")"
    chown -R "${mysqlUID}":"${mysqlGID}" "${mysqlInstallFolder}"
    cd "${mysqlInstallFolder}"
    "${mysqlInstallFolder}/scripts/mysql_install_db" --user="${mysqlUID}"
    chown -R "$(whoami)" "${mysqlInstallFolder}"
    chown -R "${mysqlUID}" "${mysqlInstallFolder}/data"
    cd "${currentPath}"

    # Config Server

    local serverConfigData=('__PORT__' "${mysqlPort}")

    createFileFromTemplate "${appPath}/../files/conf/my.cnf" "${mysqlInstallFolder}/my.cnf" "${serverConfigData[@]}"

    # Config Service

    cp -f "${mysqlInstallFolder}/support-files/mysql.server" "/etc/init.d/${mysqlServiceName}"
    sysv-rc-conf --level 2345 "${mysqlServiceName}" on

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${mysqlInstallFolder}")

    createFileFromTemplate "${appPath}/../files/profile/mysql.sh" '/etc/profile.d/mysql.sh' "${profileConfigData[@]}"

    # Start

    service "${mysqlServiceName}" start

    # Display Version

    info "\n$("${mysqlInstallFolder}/bin/mysql" --version)"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    checkRequireSystem

    header 'INSTALLING MYSQL'

    checkRequireRootUser
    checkRequirePort "${mysqlPort}"

    installDependencies
    install
    installCleanUp

    displayOpenPorts
}

main "${@}"