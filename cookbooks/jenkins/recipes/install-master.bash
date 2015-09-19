#!/bin/bash -e

function installDependencies()
{
    # Groovy

    if [[ "$(existCommand 'groovy')" = 'false' || ! -d "${JENKINS_GROOVY_INSTALL_FOLDER}" ]]
    then
        "${appPath}/../../groovy/recipes/install.bash" "${JENKINS_GROOVY_INSTALL_FOLDER}"
    fi

    # Tomcat

    if [[ ! -f "${JENKINS_TOMCAT_INSTALL_FOLDER}/bin/catalina.sh" ]]
    then
        "${appPath}/../../tomcat/recipes/install.bash" "${JENKINS_TOMCAT_INSTALL_FOLDER}"
    fi
}

function install()
{
    # Set Install Folder Path

    local -r jenkinsDefaultInstallFolder="$(getUserHomeFolder "${JENKINS_USER_NAME}")/.jenkins"

    if [[ "$(isEmptyString "${JENKINS_INSTALL_FOLDER}")" = 'true' ]]
    then
        JENKINS_INSTALL_FOLDER="${jenkinsDefaultInstallFolder}"
    fi

    # Clean Up

    jenkinsMasterWARAppCleanUp

    rm -f -r "${jenkinsDefaultInstallFolder}" "${JENKINS_INSTALL_FOLDER}"

    # Create Non-Default Jenkins Home

    if [[ "${JENKINS_INSTALL_FOLDER}" != "${jenkinsDefaultInstallFolder}" ]]
    then
        initializeFolder "${JENKINS_INSTALL_FOLDER}"
        ln -f -s "${JENKINS_INSTALL_FOLDER}" "${jenkinsDefaultInstallFolder}"
        chown -R "${JENKINS_USER_NAME}:${JENKINS_GROUP_NAME}" "${jenkinsDefaultInstallFolder}" "${JENKINS_INSTALL_FOLDER}"
    fi

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${JENKINS_INSTALL_FOLDER}")

    createFileFromTemplate "${appPath}/../templates/jenkins.sh.profile" '/etc/profile.d/jenkins.sh' "${profileConfigData[@]}"

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