#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'build-essential' 'libssl-dev'
}

function install()
{
    # Clean Up

    initializeFolder "${nginxInstallFolder}"

    # Download Dependencies

    local -r tempPCREFolder="$(getTemporaryFolder)"
    unzipRemoteFile "${nginxPCREDownloadURL}" "${tempPCREFolder}"

    local -r tempZLIBFolder="$(getTemporaryFolder)"
    unzipRemoteFile "${nginxZLIBDownloadURL}" "${tempZLIBFolder}"

    # Install

    local -r currentPath="$(pwd)"
    local -r tempFolder="$(getTemporaryFolder)"

    unzipRemoteFile "${nginxDownloadURL}" "${tempFolder}"
    addUser "${nginxUserName}" "${nginxGroupName}" 'false' 'true' 'false'
    cd "${tempFolder}"
    "${tempFolder}/configure" \
        "${nginxConfig[@]}" \
        --with-pcre="${tempPCREFolder}" \
        --with-zlib="${tempZLIBFolder}"
    make
    make install
    rm -f -r "${tempFolder}" "${tempPCREFolder}" "${tempZLIBFolder}"
    cd "${currentPath}"

    # Config Server

    local -r serverConfigData=('__PORT__' "${nginxPort}")

    createFileFromTemplate  "${appPath}/../templates/default/nginx.conf.conf" "${nginxInstallFolder}/conf/nginx.conf" "${serverConfigData[@]}"

    # Config Log

    touch "${nginxInstallFolder}/logs/access.log"
    touch "${nginxInstallFolder}/logs/error.log"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${nginxInstallFolder}")

    createFileFromTemplate "${appPath}/../templates/default/nginx.sh.profile" '/etc/profile.d/nginx.sh' "${profileConfigData[@]}"

    # Config Upstart

    local -r upstartConfigData=('__INSTALL_FOLDER__' "${nginxInstallFolder}")

    createFileFromTemplate "${appPath}/../templates/default/nginx.conf.upstart" "/etc/init/${nginxServiceName}.conf" "${upstartConfigData[@]}"

    # Start

    chown -R "${nginxUserName}:${nginxGroupName}" "${nginxInstallFolder}"
    start "${nginxServiceName}"

    # Display Version

    info "\n$("${nginxInstallFolder}/sbin/nginx" -V 2>&1)"
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING NGINX'

    checkRequirePort "${nginxPort}"

    installDependencies
    install
    installCleanUp

    displayOpenPorts
}

main "${@}"