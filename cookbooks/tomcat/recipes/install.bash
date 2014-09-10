#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${jdkInstallFolder}" ]]
    then
        "${appPath}/../../jdk/recipes/install.bash"
    fi
}

function install()
{
    # Clean Up

    initializeFolder "${tomcatInstallFolder}"

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

    createFileFromTemplate "${appPath}/../templates/default/tomcat.sh.profile" '/etc/profile.d/tomcat.sh' "${profileConfigData[@]}"

    # Add User

    addUser "${tomcatUserName}" "${tomcatGroupName}" 'true' 'true' 'true'

    local userHome="$(getUserHomeFolder "${tomcatUserName}")"

    checkExistFolder "${userHome}"

    # Config Upstart

    local upstartConfigData=(
        '__INSTALL_FOLDER__' "${tomcatInstallFolder}"
        '__HOME_FOLDER__' "${userHome}"
        '__JDK_FOLDER__' "${tomcatJDKFolder}"
        '__USER_NAME__' "${tomcatUserName}"
        '__GROUP_NAME__' "${tomcatGroupName}"
    )

    createFileFromTemplate "${appPath}/../templates/default/tomcat.conf.upstart" "/etc/init/${tomcatServiceName}.conf" "${upstartConfigData[@]}"

    # Start

    chown -R "${tomcatUserName}:${tomcatGroupName}" "${tomcatInstallFolder}"
    start "${tomcatServiceName}"

    # Display Version

    info "\n$("${tomcatInstallFolder}/bin/version.sh")"
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../lib/util.bash"
    source "${appPath}/../attributes/default.bash"
    source "${appPath}/../../jdk/attributes/default.bash"

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