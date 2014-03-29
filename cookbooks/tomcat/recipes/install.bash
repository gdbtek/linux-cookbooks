#!/bin/bash

function install()
{
    rm -rf "${installFolder}"
    mkdir -p "${installFolder}"

    curl -L "${downloadURL}" | tar xz --strip 1 -C "${installFolder}"

    # Config Server

    local tempFile="$(mktemp)"

    sed "s@8009@${ajpPort}@g" "${installFolder}/conf/server.xml" | \
    sed "s@8005@${commandPort}@g" | \
    sed "s@8080@${httpPort}@g" | \
    sed "s@8443@${httpsPort}@g" \
    > "${tempFile}"
    mv "${tempFile}" "${installFolder}/conf/server.xml"

    # Config Profile

    local newInstallFolder="$(escapeSearchPattern "${installFolder}")"

    sed "s@__INSTALL_FOLDER__@${newInstallFolder}@g" "${appPath}/../files/profile/tomcat.sh" \
    > '/etc/profile.d/tomcat.sh'

    # Config Upstart

    local newJDKFolder="$(escapeSearchPattern "${jdkFolder}")"
    local newUID="$(escapeSearchPattern "${uid}")"
    local newGID="$(escapeSearchPattern "${gid}")"

    sed "s@__INSTALL_FOLDER__@${newInstallFolder}@g" "${appPath}/../files/upstart/tomcat.conf" | \
    sed "s@__JDK_FOLDER__@${newJDKFolder}@g" | \
    sed "s@__UID__@${newUID}@g" | \
    sed "s@__GID__@${newGID}@g" \
    > "/etc/init/${serviceName}.conf"

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
    checkPortRequirement "${ajpPort} ${commandPort} ${httpPort} ${httpsPort}"

    install

    displayOpenPorts
}

main "${@}"
