#!/bin/bash -e

function installDependencies()
{
    # Groovy

    if [[ "$(existCommand 'groovy')" = 'false' || ! -d "${jenkinsGroovyInstallFolder:?}" ]]
    then
        "${appPath}/../../groovy/recipes/install.bash" "${jenkinsGroovyInstallFolder}"
    fi

    # Tomcat

    if [[ ! -f "${jenkinsTomcatInstallFolder:?}/bin/catalina.sh" ]]
    then
        "${appPath}/../../tomcat/recipes/install.bash" "${jenkinsTomcatInstallFolder}"
    fi
}

function install()
{
    # Set Install Folder Path

    local -r jenkinsDefaultInstallFolder="$(getUserHomeFolder "${jenkinsUserName:?}")/.jenkins"

    if [[ "$(isEmptyString "${jenkinsInstallFolder}")" = 'true' ]]
    then
        jenkinsInstallFolder="${jenkinsDefaultInstallFolder}"
    fi

    # Clean Up

    jenkinsMasterWARAppCleanUp

    rm -f -r "${jenkinsDefaultInstallFolder}" "${jenkinsInstallFolder}"

    # Create Non-Default Jenkins Home

    if [[ "${jenkinsInstallFolder}" != "${jenkinsDefaultInstallFolder}" ]]
    then
        initializeFolder "${jenkinsInstallFolder}"
        ln -f -s "${jenkinsInstallFolder}" "${jenkinsDefaultInstallFolder}"
        chown -R "${jenkinsUserName}:${jenkinsGroupName:?}" "${jenkinsDefaultInstallFolder}" "${jenkinsInstallFolder}"
    fi

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${jenkinsInstallFolder}")

    createFileFromTemplate "${appPath}/../templates/default/jenkins.sh.profile" '/etc/profile.d/jenkins.sh' "${profileConfigData[@]}"

    # Install

    jenkinsMasterDownloadWARApp
    jenkinsMasterDisplayVersion
    jenkinsMasterRefreshUpdateCenter
    jenkinsMasterInstallPlugins
    jenkinsMasterUpdatePlugins
    jenkinsMasterSafeRestart
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/master.bash"
    source "${appPath}/../libraries/util.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING MASTER JENKINS'

    installDependencies
    install
    installCleanUp
}

main "${@}"