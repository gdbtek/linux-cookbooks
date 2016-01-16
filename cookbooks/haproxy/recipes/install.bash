#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'build-essential' 'libssl-dev'

    if [[ ! -f "${PCRE_INSTALL_FOLDER}/bin/pcregrep" ]]
    then
        "${APP_FOLDER_PATH}/../../pcre/recipes/install.bash"
    fi
}

function install()
{
    # Clean Up

    initializeFolder "${HAPROXY_INSTALL_FOLDER}"
    initializeFolder '/etc/haproxy'

    # Install

    local -r currentPath="$(pwd)"
    local -r tempFolder="$(getTemporaryFolder)"

    unzipRemoteFile "${HAPROXY_DOWNLOAD_URL}" "${tempFolder}"
    cd "${tempFolder}"
    make "${HAPROXY_CONFIG[@]}"
    make install PREFIX='' DESTDIR="${HAPROXY_INSTALL_FOLDER}"

    rm -f -r "${tempFolder}"
    cd "${currentPath}"

    # Config Init

    local -r initConfigData=('__INSTALL_FOLDER__' "${HAPROXY_INSTALL_FOLDER}/sbin/haproxy")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/haproxy.init" '/etc/init.d/haproxy' "${initConfigData[@]}"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${HAPROXY_INSTALL_FOLDER}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/haproxy.sh.profile" '/etc/profile.d/haproxy.sh' "${profileConfigData[@]}"

    # Config Default Config

    local -r configData=('__PORT__' "${HAPROXY_PORT}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/haproxy.conf.conf" '/etc/haproxy/haproxy.cfg' "${configData[@]}"

    # Start

    addUser "${HAPROXY_USER_NAME}" "${HAPROXY_GROUP_NAME}" 'false' 'true' 'false'
    chown -R "${HAPROXY_USER_NAME}:${HAPROXY_GROUP_NAME}" "${HAPROXY_INSTALL_FOLDER}"
    service "${HAPROXY_SERVICE_NAME}" start

    # Display Open Ports

    displayOpenPorts '5'

    # Display Version

    info "\n$("${HAPROXY_INSTALL_FOLDER}/sbin/haproxy" -vv 2>&1)"
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING HAPROXY'

    checkRequirePort "${HAPROXY_PORT}"

    installDependencies
    install
    installCleanUp
}

main "${@}"