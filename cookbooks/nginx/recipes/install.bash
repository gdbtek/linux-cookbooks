#!/bin/bash

function installDependencies()
{
    runAptGetUpdate

    installPackage 'build-essential'
    installPackage 'libpcre3-dev'
    installPackage 'libssl-dev'
}

function install()
{
    # Clean Up

    rm -rf "${nginxInstallFolder}"
    mkdir -p "${nginxInstallFolder}"

    # Install

    local currentPath="$(pwd)"
    local tempFolder="$(getTemporaryFolder)"

    unzipRemoteFile "${nginxDownloadURL}" "${tempFolder}"
    cd "${tempFolder}"
    "${tempFolder}/configure" --user="${nginxUID}" --group="${nginxGID}" --prefix="${nginxInstallFolder}" --with-http_ssl_module
    make
    make install
    rm -rf "${tempFolder}"
    cd "${currentPath}"

    # Config Server

    local serverConfigData=('__PORT__' "${nginxPort}")

    createFileFromTemplate  "${appPath}/../files/conf/nginx.conf" "${nginxInstallFolder}/conf/nginx.conf" "${serverConfigData[@]}"

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${nginxInstallFolder}")

    createFileFromTemplate "${appPath}/../files/profile/nginx.sh" '/etc/profile.d/nginx.sh' "${profileConfigData[@]}"

    # Config Upstart

    local upstartConfigData=('__INSTALL_FOLDER__' "${nginxInstallFolder}")

    createFileFromTemplate "${appPath}/../files/upstart/nginx.conf" "/etc/init/${nginxServiceName}.conf" "${upstartConfigData[@]}"

    # Start

    addSystemUser "${nginxUID}" "${nginxGID}"
    chown -R "${nginxUID}":"${nginxGID}" "${nginxInstallFolder}"
    start "${nginxServiceName}"

    # Display Version

    info "\n$("${nginxInstallFolder}/sbin/nginx" --version)"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    checkRequireDistributor

    header 'INSTALLING NGINX'

    checkRequireRootUser
    checkRequirePort "${nginxPort}"

    installDependencies
    install
    installCleanUp

    displayOpenPorts
}

main "${@}"