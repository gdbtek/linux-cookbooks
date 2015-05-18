#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'build-essential' 'libssl-dev'

    if [[ ! -f "${pcreInstallFolder:?}/bin/pcregrep" ]]
    then
        "${appPath}/../../pcre/recipes/install.bash"
    fi
}

function install()
{
    # Clean Up

    initializeFolder "${haproxyInstallFolder:?}"

    # Install

    local -r currentPath="$(pwd)"
    local -r tempFolder="$(getTemporaryFolder)"

    unzipRemoteFile "${haproxyDownloadURL:?}" "${tempFolder}"
    cd "${tempFolder}"
    make "${haproxyConfig[@]}"
    make install PREFIX='' DESTDIR="${haproxyInstallFolder}"

    rm -f -r "${tempFolder}"
    cd "${currentPath}"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${haproxyInstallFolder}")

    createFileFromTemplate "${appPath}/../templates/default/haproxy.sh.profile" '/etc/profile.d/haproxy.sh' "${profileConfigData[@]}"

    # Config Upstart

    local -r upstartConfigData=('__INSTALL_FOLDER__' "${haproxyInstallFolder}")

    createFileFromTemplate "${appPath}/../templates/default/haproxy.conf.upstart" "/etc/init/${haproxyServiceName:?}.conf" "${upstartConfigData[@]}"

    # Start

    addUser "${haproxyUserName:?}" "${haproxyGroupName:?}" 'false' 'true' 'false'
    chown -R "${haproxyUserName}:${haproxyGroupName}" "${haproxyInstallFolder}"
    start "${haproxyServiceName}"

    # Display Version

    info "\n$("${haproxyInstallFolder}/sbin/haproxy" -vv 2>&1)"
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING HAPROXY'

    checkRequirePort "${haproxyPort:?}"

    installDependencies
    install
    installCleanUp

    displayOpenPorts
}

main "${@}"