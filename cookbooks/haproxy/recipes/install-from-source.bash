#!/bin/bash -e

function installDependencies()
{
    installBuildEssential
    installPackage 'libssl-dev' 'openssl-devel'

    if [[ ! -f "${PCRE_INSTALL_FOLDER_PATH}/bin/pcregrep" ]]
    then
        "$(dirname "${BASH_SOURCE[0]}")/../../pcre/recipes/install.bash"
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
    symlinkListUsrBin "${HAPROXY_INSTALL_FOLDER_PATH}/sbin/haproxy"
    cd "${currentPath}"

    # Config Init

    local -r initConfigData=('__INSTALL_FOLDER_PATH__' "${HAPROXY_INSTALL_FOLDER_PATH}/sbin/haproxy")

    createFileFromTemplate "$(dirname "${BASH_SOURCE[0]}")/../templates/haproxy.init" '/etc/init.d/haproxy' "${initConfigData[@]}"
    chmod 755 '/etc/init.d/haproxy'

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER_PATH__' "${HAPROXY_INSTALL_FOLDER_PATH}")

    createFileFromTemplate "$(dirname "${BASH_SOURCE[0]}")/../templates/haproxy.sh.profile" '/etc/profile.d/haproxy.sh' "${profileConfigData[@]}"

    # Config Default Config

    local -r configData=('__PORT__' "${HAPROXY_PORT}")

    createFileFromTemplate "$(dirname "${BASH_SOURCE[0]}")/../templates/haproxy.conf.conf" '/etc/haproxy/haproxy.cfg' "${configData[@]}"

    # Start

    addUser "${HAPROXY_USER_NAME}" "${HAPROXY_GROUP_NAME}" 'false' 'true' 'false'
    chown -R "${HAPROXY_USER_NAME}:${HAPROXY_GROUP_NAME}" "${HAPROXY_INSTALL_FOLDER_PATH}"
    service "${HAPROXY_SERVICE_NAME}" start

    # Display Open Ports

    displayOpenPorts '5'

    # Display Version

    displayVersion "$(haproxy -vv 2>&1)"
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/source.bash"

    header 'INSTALLING HAPROXY FROM SOURCE'

    checkRequireLinuxSystem
    checkRequireRootUser
    checkRequirePorts "${HAPROXY_PORT}"

    installDependencies
    install
    installCleanUp
}

main "${@}"