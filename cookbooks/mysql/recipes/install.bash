#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'libaio-dev' 'sysv-rc-conf'
}

function install()
{
    # Clean Up

    rm --force --recursive "${mysqlInstallFolder}" "/usr/local/$(getFileName "${mysqlInstallFolder}")"
    mkdir --parents "${mysqlInstallFolder}"

    # Install

    local currentPath="$(pwd)"

    unzipRemoteFile "${mysqlDownloadURL}" "${mysqlInstallFolder}"
    addSystemUser "${mysqlUserName}" "${mysqlGroupName}"
    ln --symbolic "${mysqlInstallFolder}" "/usr/local/$(getFileName "${mysqlInstallFolder}")"
    chown --recursive "${mysqlUserName}":"${mysqlGroupName}" "${mysqlInstallFolder}"
    cd "${mysqlInstallFolder}"
    "${mysqlInstallFolder}/scripts/mysql_install_db" --user="${mysqlUserName}"
    chown --recursive "$(whoami)" "${mysqlInstallFolder}"
    chown --recursive "${mysqlUserName}" "${mysqlInstallFolder}/data"
    cd "${currentPath}"

    # Config Server

    local serverConfigData=('__PORT__' "${mysqlPort}")

    createFileFromTemplate "${appPath}/../templates/default/my.cnf.conf" "${mysqlInstallFolder}/my.cnf" "${serverConfigData[@]}"

    # Config Service

    cp --force "${mysqlInstallFolder}/support-files/mysql.server" "/etc/init.d/${mysqlServiceName}"
    sysv-rc-conf --level 2345 "${mysqlServiceName}" on

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${mysqlInstallFolder}")

    createFileFromTemplate "${appPath}/../templates/default/mysql.sh.profile" '/etc/profile.d/mysql.sh' "${profileConfigData[@]}"

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
    checkRequireRootUser

    header 'INSTALLING MYSQL'

    checkRequirePort "${mysqlPort}"

    installDependencies
    install
    installCleanUp

    displayOpenPorts
}

main "${@}"