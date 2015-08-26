#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'build-essential' 'libssl-dev'

    if [[ ! -f "${PCRE_INSTALL_FOLDER}/bin/pcregrep" ]]
    then
        "${appPath}/../../pcre/recipes/install.bash"
    fi
}

function install()
{
    # Clean Up

    initializeFolder "${HAPROXY_INSTALL_FOLDER}"

    # Install

    local -r currentPath="$(pwd)"
    local -r tempFolder="$(getTemporaryFolder)"

    unzipRemoteFile "${HAPROXY_DOWNLOAD_URL}" "${tempFolder}"
    cd "${tempFolder}"
    make "${HAPROXY_CONFIG[@]}"
    make install PREFIX='' DESTDIR="${HAPROXY_INSTALL_FOLDER}"

    rm -f -r "${tempFolder}"
    cd "${currentPath}"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${HAPROXY_INSTALL_FOLDER}")

    createFileFromTemplate "${appPath}/../templates/default/haproxy.sh.profile" '/etc/profile.d/haproxy.sh' "${profileConfigData[@]}"

    # Config Upstart

    local -r upstartConfigData=('__INSTALL_FOLDER__' "${HAPROXY_INSTALL_FOLDER}")

    createFileFromTemplate "${appPath}/../templates/default/haproxy.conf.upstart" "/etc/init/${HAPROXY_SERVICE_NAME}.conf" "${upstartConfigData[@]}"

    # Start

    addUser "${HAPROXY_USER_NAME}" "${HAPROXY_GROUP_NAME}" 'false' 'true' 'false'
    chown -R "${HAPROXY_USER_NAME}:${HAPROXY_GROUP_NAME}" "${HAPROXY_INSTALL_FOLDER}"
    start "${HAPROXY_SERVICE_NAME}"

    # Display Version

    info "\n$("${HAPROXY_INSTALL_FOLDER}/sbin/haproxy" -vv 2>&1)"
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING HAPROXY'

    checkRequirePort "${HAPROXY_PORT}"

    installDependencies
    install
    installCleanUp

    displayOpenPorts '5'
}

main "${@}"