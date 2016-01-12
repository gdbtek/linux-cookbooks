#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'build-essential' 'libssl-dev'

    if [[ ! -f "${PCRE_INSTALL_FOLDER}/bin/pcregrep" ]]
    then
        "${appFolderPath}/../../pcre/recipes/install.bash"
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
    cp "${HAPROXY_INSTALL_FOLDER}/sbin/haproxy-systemd-wrapper" "/etc/init.d/${HAPROXY_SERVICE_NAME}"

    rm -f -r "${tempFolder}"
    cd "${currentPath}"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${HAPROXY_INSTALL_FOLDER}")

    createFileFromTemplate "${appFolderPath}/../templates/haproxy.sh.profile" '/etc/profile.d/haproxy.sh' "${profileConfigData[@]}"

    # Config Default Config

    local -r configData=('__PORT__' "${HAPROXY_PORT}")

    createFileFromTemplate "${appFolderPath}/../templates/haproxy.conf.conf" '/etc/haproxy/haproxy.cfg' "${configData[@]}"

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
    appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../libraries/util.bash"
    source "${appFolderPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING HAPROXY'

    checkRequirePort "${HAPROXY_PORT}"

    installDependencies
    install
    installCleanUp
}

main "${@}"