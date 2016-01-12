#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'libaio-dev' 'sysv-rc-conf'
}

function install()
{
    # Clean Up

    local -r installFolderName="$(getFileName "${MYSQL_INSTALL_FOLDER}")"

    initializeFolder "${MYSQL_INSTALL_FOLDER}"
    rm -f -r "/usr/local/${installFolderName:?}"

    # Install

    local -r currentPath="$(pwd)"

    unzipRemoteFile "${MYSQL_DOWNLOAD_URL}" "${MYSQL_INSTALL_FOLDER}"
    addUser "${MYSQL_USER_NAME}" "${MYSQL_GROUP_NAME}" 'false' 'true' 'false'
    ln -f -s "${MYSQL_INSTALL_FOLDER}" "/usr/local/$(getFileName "${MYSQL_INSTALL_FOLDER}")"
    chown -R "${MYSQL_USER_NAME}:${MYSQL_GROUP_NAME}" "${MYSQL_INSTALL_FOLDER}"
    cd "${MYSQL_INSTALL_FOLDER}"
    "${MYSQL_INSTALL_FOLDER}/bin/mysql_install_db" --user="${MYSQL_USER_NAME}"
    chown -R "$(whoami)" "${MYSQL_INSTALL_FOLDER}"
    chown -R "${MYSQL_USER_NAME}" "${MYSQL_INSTALL_FOLDER}/data"
    cd "${currentPath}"

    # Config Server

    local -r serverConfigData=('__PORT__' "${MYSQL_PORT}")

    createFileFromTemplate "${appFolderPath}/../templates/my.cnf.conf" "${MYSQL_INSTALL_FOLDER}/my.cnf" "${serverConfigData[@]}"

    # Config Service

    cp -f "${MYSQL_INSTALL_FOLDER}/support-files/mysql.server" "/etc/init.d/${MYSQL_SERVICE_NAME}"
    sysv-rc-conf --level 2345 "${MYSQL_SERVICE_NAME}" on

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${MYSQL_INSTALL_FOLDER}")

    createFileFromTemplate "${appFolderPath}/../templates/mysql.sh.profile" '/etc/profile.d/mysql.sh' "${profileConfigData[@]}"

    # Start

    service "${MYSQL_SERVICE_NAME}" start

    # Run Secure Installation

    if [[ "${MYSQL_RUN_POST_SECURE_INSTALLATION}" = 'true' ]]
    then
        secureInstallation
    fi

    # Display Open Ports

    displayOpenPorts '5'

    # Display Version

    info "\n\n$("${MYSQL_INSTALL_FOLDER}/bin/mysql" --version)"
}

function secureInstallation()
{
    local -r secureInstaller="${MYSQL_INSTALL_FOLDER}/bin/mysql_secure_installation"

    checkExistFile "${secureInstaller}"

    # Install Expect

    installAptGetPackages 'expect'

    # Config Option

    local setMySQLRootPassword='n'

    if [[ "${MYSQL_ROOT_PASSWORD}" != '' ]]
    then
        setMySQLRootPassword='Y'
    fi

    if [[ "${MYSQL_DELETE_ANONYMOUS_USERS}" = 'true' ]]
    then
        MYSQL_DELETE_ANONYMOUS_USERS='Y'
    else
        MYSQL_DELETE_ANONYMOUS_USERS='n'
    fi

    if [[ "${MYSQL_DISALLOW_ROOT_LOGIN_REMOTELY}" = 'true' ]]
    then
        MYSQL_DISALLOW_ROOT_LOGIN_REMOTELY='Y'
    else
        MYSQL_DISALLOW_ROOT_LOGIN_REMOTELY='n'
    fi

    if [[ "${MYSQL_DELETE_TEST_DATABASE}" = 'true' ]]
    then
        MYSQL_DELETE_TEST_DATABASE='Y'
    else
        MYSQL_DELETE_TEST_DATABASE='n'
    fi

    if [[ "${MYSQL_RELOAD_PRIVILEGE_TABLE}" = 'true' ]]
    then
        MYSQL_RELOAD_PRIVILEGE_TABLE='Y'
    else
        MYSQL_RELOAD_PRIVILEGE_TABLE='n'
    fi

    # Run Config

    cd "${MYSQL_INSTALL_FOLDER}"

    expect << DONE
        set timeout 3
        spawn "${secureInstaller}"

        expect "Enter current password for root (enter for none): "
        send -- "\r"

        expect "Set root password? \[Y/n] "
        send -- "${setMySQLRootPassword}\r"

        if { "${setMySQLRootPassword}" == "Y" } {
            expect "New password: "
            send -- "${MYSQL_ROOT_PASSWORD}\r"

            expect "Re-enter new password: "
            send -- "${MYSQL_ROOT_PASSWORD}\r"
        }

        expect "Remove anonymous users? \[Y/n] "
        send -- "${MYSQL_DELETE_ANONYMOUS_USERS}\r"

        expect "Disallow root login remotely? \[Y/n] "
        send -- "${MYSQL_DISALLOW_ROOT_LOGIN_REMOTELY}\r"

        expect "Remove test database and access to it? \[Y/n] "
        send -- "${MYSQL_DELETE_TEST_DATABASE}\r"

        expect "Reload privilege tables now? \[Y/n] "
        send -- "${MYSQL_RELOAD_PRIVILEGE_TABLE}\r"

        expect eof
DONE
}

function main()
{
    appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../libraries/util.bash"
    source "${appFolderPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING MYSQL'

    checkRequirePort "${MYSQL_PORT}"

    installDependencies
    install
    installCleanUp
}

main "${@}"