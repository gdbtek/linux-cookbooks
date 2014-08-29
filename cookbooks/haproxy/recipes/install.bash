#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'build-essential' 'libssl-dev'

    if [[ ! -f "${pcreInstallFolder}/bin/pcregrep" ]]
    then
        "${appPath}/../../pcre/recipes/install.bash"
    fi
}

function install()
{
    # Clean Up

    rm -f -r "${haproxyInstallFolder}"
    mkdir -p "${haproxyInstallFolder}"

    # Install

    local currentPath="$(pwd)"
    local tempFolder="$(getTemporaryFolder)"

    unzipRemoteFile "${haproxyDownloadURL}" "${tempFolder}"
    cd "${tempFolder}"
    make "${haproxyConfig[@]}"
    make install PREFIX='' DESTDIR="${haproxyInstallFolder}"

    rm -f -r "${tempFolder}"
    cd "${currentPath}"

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${haproxyInstallFolder}")

    createFileFromTemplate "${appPath}/../templates/default/haproxy.sh.profile" '/etc/profile.d/haproxy.sh' "${profileConfigData[@]}"

    # Config Upstart

    local upstartConfigData=('__INSTALL_FOLDER__' "${haproxyInstallFolder}")

    createFileFromTemplate "${appPath}/../templates/default/haproxy.conf.upstart" "/etc/init/${haproxyServiceName}.conf" "${upstartConfigData[@]}"

    # Start

    addSystemUser "${haproxyUserName}" "${haproxyGroupName}"
    chown -R "${haproxyUserName}:${haproxyGroupName}" "${haproxyInstallFolder}"
    start "${haproxyServiceName}"

    # Display Version

    info "\n$("${haproxyInstallFolder}/sbin/haproxy" -vv 2>&1)"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING HAPROXY'

    checkRequirePort "${haproxyPort}"

    installDependencies
    install
    installCleanUp

    displayOpenPorts
}

main "${@}"