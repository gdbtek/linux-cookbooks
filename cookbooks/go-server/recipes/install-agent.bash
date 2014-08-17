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

    rm --force --recursive "${goserverAgentInstallFolder}"
    mkdir --parents "${goserverAgentInstallFolder}"

    # Install

    addgroup "${goserverGroupName}" >> /dev/null 2>&1
    useradd "${goserverUserName}" --gid "${goserverGroupName}" --shell '/bin/bash' --create-home
    unzipRemoteFile "${goserverAgentDownloadURL}" "${goserverAgentInstallFolder}"

    local unzipFolderName="$(ls --directory ${goserverAgentInstallFolder}/*/ 2> '/dev/null')"

    if [[ "$(isEmptyString "${unzipFolderName}")" = 'false' && "$(echo "${unzipFolderName}" | wc --lines)" = '1' ]]
    then
        if [[ "$(ls --almost-all "${unzipFolderName}")" != '' ]]
        then
            mv ${unzipFolderName}* "${goserverAgentInstallFolder}" &&
            chown --recursive "${goserverUserName}":"${goserverGroupName}" "${goserverAgentInstallFolder}" &&
            rm --force --recursive "${unzipFolderName}"
        else
            fatal "FATAL: folder '${unzipFolderName}' is empty"
        fi
    else
        fatal 'FATAL: found multiple unzip folder name!'
    fi
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

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1
    source "${appPath}/../../jdk/attributes/default.bash" || exit 1

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