#!/bin/bash -e

function installDependencies()
{
    installBuildEssential
    installPackage 'libssl-dev' 'openssl-devel'

    if [[ ! -f "${PCRE_INSTALL_FOLDER_PATH}/bin/pcregrep" ]]
    then
        "${APP_FOLDER_PATH}/../../pcre/recipes/install.bash"
    fi
}

function install()
{
    # Clean Up

    initializeFolder "${HAPROXY_INSTALL_FOLDER_PATH}"
    initializeFolder '/etc/haproxy'

    # Install

    local -r currentPath="$(pwd)"
    local -r tempFolder="$(getTemporaryFolder)"

    unzipRemoteFile "${HAPROXY_DOWNLOAD_URL}" "${tempFolder}"
    cd "${tempFolder}"
    make "${HAPROXY_CONFIG[@]}"
    make install PREFIX='' DESTDIR="${HAPROXY_INSTALL_FOLDER_PATH}"
    rm -f -r "${tempFolder}"
    ln -f -s "${HAPROXY_INSTALL_FOLDER_PATH}/sbin/haproxy" '/usr/local/bin/haproxy'
    cd "${currentPath}"

    # Config Init

    local -r initConfigData=('__INSTALL_FOLDER_PATH__' "${HAPROXY_INSTALL_FOLDER_PATH}/sbin/haproxy")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/haproxy.init" '/etc/init.d/haproxy' "${initConfigData[@]}"
    chmod 755 '/etc/init.d/haproxy'

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER_PATH__' "${HAPROXY_INSTALL_FOLDER_PATH}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/haproxy.sh.profile" '/etc/profile.d/haproxy.sh' "${profileConfigData[@]}"

    # Config Default Config

    local -r configData=('__PORT__' "${HAPROXY_PORT}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/haproxy.conf.conf" '/etc/haproxy/haproxy.cfg' "${configData[@]}"

    # Start

    addUser "${HAPROXY_USER_NAME}" "${HAPROXY_GROUP_NAME}" 'false' 'true' 'false'
    chown -R "${HAPROXY_USER_NAME}:${HAPROXY_GROUP_NAME}" "${HAPROXY_INSTALL_FOLDER_PATH}"
    service "${HAPROXY_SERVICE_NAME}" start

    # Display Open Ports

    displayOpenPorts '5'

    # Display Version

    displayVersion "$("${HAPROXY_INSTALL_FOLDER_PATH}/sbin/haproxy" -vv 2>&1)"
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/source.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING HAPROXY FROM SOURCE'

    checkRequirePorts "${HAPROXY_PORT}"

    installDependencies
    install
    installCleanUp
}

main "${@}"