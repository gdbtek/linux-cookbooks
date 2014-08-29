#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'libaio-dev' 'sysv-rc-conf'
}

function install()
{
    # Clean Up

    rm -f -r "${mysqlInstallFolder}" "/usr/local/$(getFileName "${mysqlInstallFolder}")"
    mkdir -p "${mysqlInstallFolder}"

    # Install

    local currentPath="$(pwd)"

    unzipRemoteFile "${mysqlDownloadURL}" "${mysqlInstallFolder}"
    addUser "${mysqlUserName}" "${mysqlGroupName}" 'false' 'true' 'false'
    ln -s "${mysqlInstallFolder}" "/usr/local/$(getFileName "${mysqlInstallFolder}")"
    chown -R "${mysqlUserName}:${mysqlGroupName}" "${mysqlInstallFolder}"
    cd "${mysqlInstallFolder}"
    "${mysqlInstallFolder}/scripts/mysql_install_db" --user="${mysqlUserName}"
    chown -R "$(whoami)" "${mysqlInstallFolder}"
    chown -R "${mysqlUserName}" "${mysqlInstallFolder}/data"
    cd "${currentPath}"

    # Config Server

    local serverConfigData=('__PORT__' "${mysqlPort}")

    createFileFromTemplate "${appPath}/../templates/default/my.cnf.conf" "${mysqlInstallFolder}/my.cnf" "${serverConfigData[@]}"

    # Config Service

    cp -f "${mysqlInstallFolder}/support-files/mysql.server" "/etc/init.d/${mysqlServiceName}"
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

    source "${appPath}/../../../lib/util.bash"
    source "${appPath}/../attributes/default.bash"

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