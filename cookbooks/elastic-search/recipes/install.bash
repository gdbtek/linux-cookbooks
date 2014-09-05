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

    initializeFolder "${elasticsearchInstallFolder}"

    # Install

    unzipRemoteFile "${elasticsearchDownloadURL}" "${elasticsearchInstallFolder}"

    # Config Server

    local serverConfigData=(
        '__HTTP_PORT__' "${elasticsearchHTTPPort}"
        '__TRANSPORT_TCP_PORT__' "${elasticsearchTransportTCPPort}"
    )

    createFileFromTemplate  "${appPath}/../templates/default/elasticsearch.yml.conf" "${elasticsearchInstallFolder}/config/elasticsearch.yml" "${serverConfigData[@]}"

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${elasticsearchInstallFolder}")

    createFileFromTemplate "${appPath}/../templates/default/elastic-search.sh.profile" '/etc/profile.d/elastic-search.sh' "${profileConfigData[@]}"

    # Config Upstart

    local upstartConfigData=(
        '__INSTALL_FOLDER__' "${elasticsearchInstallFolder}"
        '__JDK_FOLDER__' "${elasticsearchJDKFolder}"
        '__USER_NAME__' "${elasticsearchUserName}"
        '__GROUP_NAME__' "${elasticsearchGroupName}"
    )

    createFileFromTemplate "${appPath}/../templates/default/elastic-search.conf.upstart" "/etc/init/${elasticsearchServiceName}.conf" "${upstartConfigData[@]}"

    # Start

    addUser "${elasticsearchUserName}" "${elasticsearchGroupName}" 'false' 'true' 'false'
    chown -R "${elasticsearchUserName}:${elasticsearchGroupName}" "${elasticsearchInstallFolder}"
    start "${elasticsearchServiceName}"

    # Display Version

    info "\n$("${elasticsearchInstallFolder}/bin/elasticsearch" -v)"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash"
    source "${appPath}/../attributes/default.bash"
    source "${appPath}/../../jdk/attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING ELASTIC SEARCH'

    checkRequirePort "${elasticsearchHTTPPort}" "${elasticsearchTransportTCPPort}"

    installDependencies
    install
    installCleanUp

    displayOpenPorts
}

main "${@}"