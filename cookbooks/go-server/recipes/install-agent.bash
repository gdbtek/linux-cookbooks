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

    rm -f -r "${goserverAgentInstallFolder}"
    mkdir -p "${goserverAgentInstallFolder}"

    # Install

    addUser "${goserverUserName}" "${goserverGroupName}" 'true' 'false' 'true'
    unzipRemoteFile "${goserverAgentDownloadURL}" "${goserverAgentInstallFolder}"

    local unzipFolderName="$(ls -d ${goserverAgentInstallFolder}/*/ 2> '/dev/null')"

    if [[ "$(isEmptyString "${unzipFolderName}")" = 'true' || "$(echo "${unzipFolderName}" | wc -l)" != '1' ]]
    then
        fatal 'FATAL : found multiple unzip folder name!'
    fi

    if [[ "$(ls -A "${unzipFolderName}")" = '' ]]
    then
        fatal "FATAL : folder '${unzipFolderName}' is empty"
    fi

    mv ${unzipFolderName}* "${goserverAgentInstallFolder}"
    chown -R "${goserverUserName}:${goserverGroupName}" "${goserverAgentInstallFolder}"
    rm -f -r "${unzipFolderName}"
}

function configUpstart()
{
    local serverHostname="${1}"

    if [[ "$(isEmptyString "${serverHostname}")" = 'true' ]]
    then
        serverHostname='127.0.0.1'
    fi

    local upstartConfigData=(
        '__AGENT_INSTALL_FOLDER__' "${goserverAgentInstallFolder}"
        '__SERVER_HOSTNAME__' "${serverHostname}"
        '__GO_HOME_FOLDER__' "$(getUserHomeFolder "${goserverUserName}")"
        '__USER_NAME__' "${goserverUserName}"
        '__GROUP_NAME__' "${goserverGroupName}"
    )

    createFileFromTemplate "${appPath}/../templates/default/go-agent.conf.upstart" "/etc/init/${goserverAgentServiceName}.conf" "${upstartConfigData[@]}"
}

function startAgent()
{
    start "${goserverAgentServiceName}"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash"
    source "${appPath}/../attributes/default.bash"
    source "${appPath}/../../jdk/attributes/default.bash"

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