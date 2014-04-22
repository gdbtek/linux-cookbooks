#!/bin/bash

function installDependencies()
{
    apt-get update

    apt-get install -y build-essential
    apt-get install -y libpcre3-dev
    apt-get install -y libssl-dev
}

function install()
{
    # Clean Up

    rm -rf "${installFolder}"
    mkdir -p "${installFolder}"

    # Install

    local currentPath="$(pwd)"
    local tempFolder="$(getTemporaryFolder)"

    unzipRemoteFile "${downloadURL}" "${tempFolder}"
    cd "${tempFolder}"
    "${tempFolder}/configure" --user="${uid}" --group="${gid}" --prefix="${installFolder}" --with-http_ssl_module
    make
    make install
    rm -rf "${tempFolder}"
    cd "${currentPath}"

    # Config Server

    local serverConfigData=('__PORT__' "${port}")

    createFileFromTemplate  "${appPath}/../files/conf/nginx.conf" "${installFolder}/conf/nginx.conf" "${serverConfigData[@]}"

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${installFolder}")

    createFileFromTemplate "${appPath}/../files/profile/nginx.sh" '/etc/profile.d/nginx.sh' "${profileConfigData[@]}"

    # Config Upstart

    local upstartConfigData=('__INSTALL_FOLDER__' "${installFolder}")

    createFileFromTemplate "${appPath}/../files/upstart/nginx.conf" "/etc/init/${serviceName}.conf" "${upstartConfigData[@]}"

    # Start

    addSystemUser "${uid}" "${gid}"
    chown -R "${uid}":"${gid}" "${installFolder}"
    start "${serviceName}"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    header 'INSTALLING NGINX'

    checkRequireRootUser
    checkPortRequirement "${port}"

    installDependencies
    install

    displayOpenPorts
}

main "${@}"
