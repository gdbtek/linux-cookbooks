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

    # Run Secure Installation

    secureInstallation

    # Display Version

    info "\n$("${mysqlInstallFolder}/bin/mysql" --version)"
}

function secureInstallation()
{
    local secureInstaller="${mysqlInstallFolder}/bin/mysql_secure_installation"

    if [[ ! -f "${secureInstaller}" ]]
    then
        fatal "\nFATAL : file '${secureInstaller}' not found!"
    fi

    # Install Expect

    installAptGetPackages 'expect'

    # Config Option

    local setMySQLRootPassword='n'

    if [[ "${mysqlRootPassword}" != '' ]]
    then
        setMySQLRootPassword='y'
    fi

    if [[ "${mysqlRemoveAnonymousUsers}" = 'false' ]]
    then
        mysqlRemoveAnonymousUsers='n'
    else
        mysqlRemoveAnonymousUsers='Y'
    fi

    if [[ "${mysqlDisallowRootLoginRemotely}" = 'false' ]]
    then
        mysqlDisallowRootLoginRemotely='n'
    else
        mysqlDisallowRootLoginRemotely='Y'
    fi

    if [[ "${mysqlRemoveTestDatabase}" = 'false' ]]
    then
        mysqlRemoveTestDatabase='n'
    else
        mysqlRemoveTestDatabase='Y'
    fi

    if [[ "${mysqlReloadPrivilegeTable}" = 'true' ]]
    then
        mysqlReloadPrivilegeTable='Y'
    else
        mysqlReloadPrivilegeTable='n'
    fi

    # Run Config

    cd "${mysqlInstallFolder}"

    expect << DONE
        spawn "${secureInstaller}"
        expect "Set root password? [Y\/n] "
        send -- "${setMySQLRootPassword}\r"
        expect "Remove anonymous users? [Y\/n] "
        send -- "${mysqlRemoveAnonymousUsers}\r"
        expect "Disallow root login remotely? [Y\/n] "
        send -- "${mysqlDisallowRootLoginRemotely}\r"
        expect "Remove test database and access to it? [Y\/n] "
        send -- "${mysqlRemoveTestDatabase}\r"
        expect "Reload privilege tables now? [Y\/n] "
        send -- "${mysqlReloadPrivilegeTable}\r"
        expect eof
DONE
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