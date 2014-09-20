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

    local tempPCREFolder="$(getTemporaryFolder)"
    unzipRemoteFile "${nginxPCREDownloadURL}" "${tempPCREFolder}"

    local tempZLIBFolder="$(getTemporaryFolder)"
    unzipRemoteFile "${nginxZLIBDownloadURL}" "${tempZLIBFolder}"

    # Install

    local currentPath="$(pwd)"
    local tempFolder="$(getTemporaryFolder)"

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

    local serverConfigData=('__PORT__' "${nginxPort}")

    createFileFromTemplate  "${appPath}/../templates/default/nginx.conf.conf" "${nginxInstallFolder}/conf/nginx.conf" "${serverConfigData[@]}"

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${nginxInstallFolder}")

    createFileFromTemplate "${appPath}/../templates/default/nginx.sh.profile" '/etc/profile.d/nginx.sh' "${profileConfigData[@]}"

    # Config Upstart

    local upstartConfigData=('__INSTALL_FOLDER__' "${nginxInstallFolder}")

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