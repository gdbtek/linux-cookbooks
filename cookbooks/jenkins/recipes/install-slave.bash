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
    # Set Install Folder Path

    local jenkinsDefaultInstallFolder="$(getUserHomeFolder "${jenkinsUserName}")/.jenkins"

    if [[ "$(isEmptyString "${jenkinsInstallFolder}")" = 'true' ]]
    then
        jenkinsInstallFolder="${jenkinsDefaultInstallFolder}"
    fi

    # Clean Up

    local appName="$(getFileName "${jenkinsDownloadURL}")"

    rm -f -r "${jenkinsDefaultInstallFolder}" \
             "${jenkinsInstallFolder}" \
             "${jenkinsTomcatInstallFolder}/webapps/${appName}.war" \
             "${jenkinsTomcatInstallFolder}/webapps/${appName}"

    # Create Non-Default Jenkins Home

    if [[ "${jenkinsInstallFolder}" != "${jenkinsDefaultInstallFolder}" ]]
    then
        initializeFolder "${jenkinsInstallFolder}"
        ln -s "${jenkinsInstallFolder}" "${jenkinsDefaultInstallFolder}"
        chown -R "${jenkinsUserName}:${jenkinsGroupName}" "${jenkinsDefaultInstallFolder}" "${jenkinsInstallFolder}"
    fi
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../lib/util.bash"
    source "${appPath}/../attributes/master.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING SLAVE JENKINS'

    installDependencies
    install
    installCleanUp
}

main "${@}"