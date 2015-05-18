#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'java')" = 'false' || ! -d "${goserverJDKInstallFolder:?}" ]]
    then
        "${appPath}/../../jdk/recipes/install.bash" "${goserverJDKInstallFolder}"
    fi
}

function install()
{
    # Clean Up

    initializeFolder "${goserverAgentInstallFolder:?}"

    # Install

    unzipRemoteFile "${goserverAgentDownloadURL:?}" "${goserverAgentInstallFolder}"

    local -r unzipFolder="$(find "${goserverServerInstallFolder:?}" -maxdepth 1 -xtype d 2> '/dev/null' | tail -1)"

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
    find '.' -maxdepth 1 -not -name '.' -exec mv '{}' "${goserverAgentInstallFolder}" \;
    cd "${currentPath}"

    # Finalize

    addUser "${goserverUserName:?}" "${goserverGroupName:?}" 'true' 'false' 'true'
    chown -R "${goserverUserName}:${goserverGroupName}" "${goserverAgentInstallFolder}"
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
        '__AGENT_INSTALL_FOLDER__' "${goserverAgentInstallFolder}"
        '__SERVER_HOSTNAME__' "${serverHostname}"
        '__GO_HOME_FOLDER__' "$(getUserHomeFolder "${goserverUserName}")"
        '__USER_NAME__' "${goserverUserName}"
        '__GROUP_NAME__' "${goserverGroupName}"
    )

    createFileFromTemplate "${appPath}/../templates/default/go-agent.conf.upstart" "/etc/init/${goserverAgentServiceName:?}.conf" "${upstartConfigData[@]}"
}

function startAgent()
{
    start "${goserverAgentServiceName}"
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