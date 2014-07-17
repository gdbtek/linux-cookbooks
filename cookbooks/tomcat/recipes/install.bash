#!/bin/bash

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' ]]
    then
        "${appPath}/../../jdk/recipes/install.bash"
    fi
}

function install()
{
    # Clean Up

    rm -rf "${tomcatInstallFolder}"
    mkdir -p "${tomcatInstallFolder}"

    # Install

    unzipRemoteFile "${tomcatDownloadURL}" "${tomcatInstallFolder}"

    # Config Server

    local serverConfigData=(
        8009 "${tomcatAJPPort}"
        8005 "${tomcatCommandPort}"
        8080 "${tomcatHTTPPort}"
        8443 "${tomcatHTTPSPort}"
    )

    createFileFromTemplate "${tomcatInstallFolder}/conf/server.xml" "${tomcatInstallFolder}/conf/server.xml" "${serverConfigData[@]}"

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${tomcatInstallFolder}")

    createFileFromTemplate "${appPath}/../files/profile/tomcat.sh" '/etc/profile.d/tomcat.sh' "${profileConfigData[@]}"

    # Config Upstart

    local upstartConfigData=(
        '__INSTALL_FOLDER__' "${tomcatInstallFolder}"
        '__JDK_FOLDER__' "${tomcatJDKFolder}"
        '__UID__' "${tomcatUID}"
        '__GID__' "${tomcatGID}"
    )

    createFileFromTemplate "${appPath}/../files/upstart/tomcat.conf" "/etc/init/${tomcatServiceName}.conf" "${upstartConfigData[@]}"

    # Start

    addSystemUser "${tomcatUID}" "${tomcatGID}"
    chown -R "${tomcatUID}":"${tomcatGID}" "${tomcatInstallFolder}"
    start "${tomcatServiceName}"

    # Display Version

    info "\n$("${tomcatInstallFolder}/bin/version.sh")"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING TOMCAT'

    checkRequirePort "${tomcatAJPPort}" "${tomcatCommandPort}" "${tomcatHTTPPort}" "${tomcatHTTPSPort}"

    installDependencies
    install
    installCleanUp

    displayOpenPorts
}

main "${@}"