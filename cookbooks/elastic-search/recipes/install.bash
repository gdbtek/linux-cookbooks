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

    rm -rf "${elasticsearchInstallFolder}"
    mkdir -p "${elasticsearchInstallFolder}"

    # Install

    unzipRemoteFile "${elasticsearchDownloadURL}" "${elasticsearchInstallFolder}"

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${elasticsearchInstallFolder}")

    createFileFromTemplate "${appPath}/../files/profile/elastic-search.sh" '/etc/profile.d/elastic-search.sh' "${profileConfigData[@]}"

    # Config Upstart

    if [[ "$(isEmptyString "${elasticsearchJDKFolder}")" = 'true' ]]
    then
        local elasticsearchJDKFolder="${jdkInstallFolder}"
    fi

    local upstartConfigData=(
        '__INSTALL_FOLDER__' "${elasticsearchInstallFolder}"
        '__JDK_FOLDER__' "${elasticsearchJDKFolder}"
        '__UID__' "${elasticsearchUID}"
        '__GID__' "${elasticsearchGID}"
    )

    createFileFromTemplate "${appPath}/../files/upstart/elastic-search.conf" "/etc/init/${elasticsearchServiceName}.conf" "${upstartConfigData[@]}"

    # Start

    addSystemUser "${elasticsearchUID}" "${elasticsearchGID}"
    chown -R "${elasticsearchUID}":"${elasticsearchGID}" "${elasticsearchInstallFolder}"
    start "${elasticsearchServiceName}"

    # Display Version

    info "\n$("${elasticsearchInstallFolder}/bin/elasticsearch" -v)"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1
    source "${appPath}/../../jdk/attributes/default.bash" || exit 1

    checkRequireDistributor

    header 'INSTALLING ELASTIC SEARCH'

    checkRequireRootUser
    checkRequirePort "${elasticsearchHTTPPort}" "${elasticsearchTransportTCPPort}"

    installDependencies
    install
    installCleanUp

    displayOpenPorts
}

main "${@}"