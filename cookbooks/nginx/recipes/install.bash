#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'build-essential' 'libssl-dev'
}

function install()
{
    # Clean Up

    initializeFolder "${NGINX_INSTALL_FOLDER}"

    # Download Dependencies

    local -r tempPCREFolder="$(getTemporaryFolder)"
    unzipRemoteFile "${NGINX_PCRE_DOWNLOAD_URL}" "${tempPCREFolder}"

    local -r tempZLIBFolder="$(getTemporaryFolder)"
    unzipRemoteFile "${NGINX_ZLIB_DOWNLOAD_URL}" "${tempZLIBFolder}"

    # Install

    local -r currentPath="$(pwd)"
    local -r tempFolder="$(getTemporaryFolder)"

    unzipRemoteFile "${NGINX_DOWNLOAD_URL}" "${tempFolder}"
    addUser "${NGINX_USER_NAME}" "${NGINX_GROUP_NAME}" 'false' 'true' 'false'
    cd "${tempFolder}"
    "${tempFolder}/configure" \
        "${NGINX_CONFIG[@]}" \
        --with-pcre="${tempPCREFolder}" \
        --with-zlib="${tempZLIBFolder}"
    make
    make install
    rm -f -r "${tempFolder}" "${tempPCREFolder}" "${tempZLIBFolder}"
    cd "${currentPath}"

    # Config Server

    local -r serverConfigData=('__PORT__' "${NGINX_PORT}")

    createFileFromTemplate  "${appPath}/../templates/nginx.conf.conf" "${NGINX_INSTALL_FOLDER}/conf/nginx.conf" "${serverConfigData[@]}"

    # Config Log

    touch "${NGINX_INSTALL_FOLDER}/logs/access.log"
    touch "${NGINX_INSTALL_FOLDER}/logs/error.log"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${NGINX_INSTALL_FOLDER}")

    createFileFromTemplate "${appPath}/../templates/nginx.sh.profile" '/etc/profile.d/nginx.sh' "${profileConfigData[@]}"

    # Config Upstart

    local -r upstartConfigData=('__INSTALL_FOLDER__' "${NGINX_INSTALL_FOLDER}")

    createFileFromTemplate "${appPath}/../templates/nginx.conf.upstart" "/etc/init/${NGINX_SERVICE_NAME}.conf" "${upstartConfigData[@]}"

    # Start

    chown -R "${NGINX_USER_NAME}:${NGINX_GROUP_NAME}" "${NGINX_INSTALL_FOLDER}"
    start "${NGINX_SERVICE_NAME}"

    # Display Open Ports

    displayOpenPorts '5'

    # Display Version

    info "\n$("${NGINX_INSTALL_FOLDER}/sbin/nginx" -V 2>&1)"
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING NGINX'

    checkRequirePort "${NGINX_PORT}"

    installDependencies
    install
    installCleanUp
}

main "${@}"