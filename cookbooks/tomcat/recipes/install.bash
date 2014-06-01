#!/bin/bash

function install()
{
    # Clean Up

    rm -rf "${installFolder}"
    mkdir -p "${installFolder}"

    # Install

    unzipRemoteFile "${downloadURL}" "${installFolder}"

    # Config Server

    local serverConfigData=(
        8009 "${ajpPort}"
        8005 "${commandPort}"
        8080 "${httpPort}"
        8443 "${httpsPort}"
    )

    createFileFromTemplate "${installFolder}/conf/server.xml" "${installFolder}/conf/server.xml" "${serverConfigData[@]}"

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${installFolder}")

    createFileFromTemplate "${appPath}/../files/profile/tomcat.sh" '/etc/profile.d/tomcat.sh' "${profileConfigData[@]}"

    # Config Upstart

    local upstartConfigData=(
        '__INSTALL_FOLDER__' "${installFolder}"
        '__JDK_FOLDER__' "${jdkFolder}"
        '__UID__' "${uid}"
        '__GID__' "${gid}"
    )

    createFileFromTemplate "${appPath}/../files/upstart/tomcat.conf" "/etc/init/${serviceName}.conf" "${upstartConfigData[@]}"

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

    header 'INSTALLING TOMCAT'

    checkRequireRootUser
    checkRequirePort "${ajpPort}" "${commandPort}" "${httpPort}" "${httpsPort}"

    install
    installCleanUp

    displayOpenPorts
}

main "${@}"
