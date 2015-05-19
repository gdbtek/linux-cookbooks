#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${GO_SERVER_JDK_INSTALL_FOLDER}" ]]
    then
        "${appPath}/../../jdk/recipes/install.bash" "${GO_SERVER_JDK_INSTALL_FOLDER}"
    fi
}

function install()
{
    # Clean Up

    initializeFolder "${GO_SERVER_AGENT_INSTALL_FOLDER}"

    # Install

    unzipRemoteFile "${GO_SERVER_AGENT_DOWNLOAD_URL}" "${GO_SERVER_AGENT_INSTALL_FOLDER}"

    local -r unzipFolder="$(find "${GO_SERVER_SERVER_INSTALL_FOLDER}" -maxdepth 1 -xtype d 2> '/dev/null' | tail -1)"

    if [[ "$(isEmptyString "${unzipFolder}")" = 'true' || "$(wc -l <<< "${unzipFolder}")" != '1' ]]
    then
        fatal 'FATAL : multiple unzip folder names found'
    fi

    if [[ "$(ls -A "${unzipFolder}")" = '' ]]
    then
        fatal "FATAL : folder '${unzipFolder}' empty"
    fi

    # Move Folder

    local -r currentPath="$(pwd)"

    cd "${unzipFolder}"
    find '.' -maxdepth 1 -not -name '.' -exec mv '{}' "${GO_SERVER_AGENT_INSTALL_FOLDER}" \;
    cd "${currentPath}"

    # Finalize

    addUser "${GO_SERVER_USER_NAME}" "${GO_SERVER_GROUP_NAME}" 'true' 'false' 'true'
    chown -R "${GO_SERVER_USER_NAME}:${GO_SERVER_GROUP_NAME}" "${GO_SERVER_AGENT_INSTALL_FOLDER}"
    rm -f -r "${unzipFolder}"
}

function configUpstart()
{
    local serverHostname="${1}"

    if [[ "$(isEmptyString "${serverHostname}")" = 'true' ]]
    then
        serverHostname='127.0.0.1'
    fi

    local -r upstartConfigData=(
        '__AGENT_INSTALL_FOLDER__' "${GO_SERVER_AGENT_INSTALL_FOLDER}"
        '__SERVER_HOSTNAME__' "${serverHostname}"
        '__GO_HOME_FOLDER__' "$(getUserHomeFolder "${GO_SERVER_USER_NAME}")"
        '__USER_NAME__' "${GO_SERVER_USER_NAME}"
        '__GROUP_NAME__' "${GO_SERVER_GROUP_NAME}"
    )

    createFileFromTemplate "${appPath}/../templates/default/go-agent.conf.upstart" "/etc/init/${GO_SERVER_AGENT_SERVICE_NAME}.conf" "${upstartConfigData[@]}"
}

function startAgent()
{
    start "${GO_SERVER_AGENT_SERVICE_NAME}"
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING GO-SERVER (AGENT)'

    installDependencies
    install
    configUpstart "${@}"
    startAgent
    installCleanUp
}

main "${@}"