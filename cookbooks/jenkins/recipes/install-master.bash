#!/bin/bash -e

function installDependencies()
{
    # Groovy

    if [[ "$(existCommand 'groovy')" = 'false' || ! -d "${JENKINS_GROOVY_INSTALL_FOLDER_PATH}" ]]
    then
        "${APP_FOLDER_PATH}/../../groovy/recipes/install.bash" "${JENKINS_GROOVY_INSTALL_FOLDER_PATH}"
    fi

    # Tomcat

    if [[ ! -f "${JENKINS_TOMCAT_INSTALL_FOLDER_PATH}/bin/catalina.sh" ]]
    then
        "${APP_FOLDER_PATH}/../../tomcat/recipes/install.bash" "${JENKINS_TOMCAT_INSTALL_FOLDER_PATH}"
    fi
}

function install()
{
    umask '0022'

    # Set Install Folder Path

    local -r jenkinsDefaultInstallFolder="$(getUserHomeFolder "${JENKINS_USER_NAME}")/.jenkins"

    if [[ "$(isEmptyString "${JENKINS_INSTALL_FOLDER_PATH}")" = 'true' ]]
    then
        JENKINS_INSTALL_FOLDER_PATH="${jenkinsDefaultInstallFolder}"
    fi

    # Clean Up

    jenkinsMasterWARAppCleanUp

    rm -f -r "${jenkinsDefaultInstallFolder}" "${JENKINS_INSTALL_FOLDER_PATH}"

    # Create Non-Default Jenkins Home

    if [[ "${JENKINS_INSTALL_FOLDER_PATH}" != "${jenkinsDefaultInstallFolder}" ]]
    then
        initializeFolder "${JENKINS_INSTALL_FOLDER_PATH}"
        ln -f -s "${JENKINS_INSTALL_FOLDER_PATH}" "${jenkinsDefaultInstallFolder}"
        chown -R "${JENKINS_USER_NAME}:${JENKINS_GROUP_NAME}" "${jenkinsDefaultInstallFolder}" "${JENKINS_INSTALL_FOLDER_PATH}"
    fi

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER_PATH__' "${JENKINS_INSTALL_FOLDER_PATH}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/jenkins.sh.profile" '/etc/profile.d/jenkins.sh' "${profileConfigData[@]}"

    # Config Cron

    local -r cronConfigData=(
        '__USER_NAME__' "${JENKINS_USER_NAME}"
        '__GROUP_NAME__' "${JENKINS_GROUP_NAME}"
        '__INSTALL_FOLDER_PATH__' "${JENKINS_INSTALL_FOLDER_PATH}"
    )

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/jenkins.cron" '/etc/cron.daily/jenkins' "${cronConfigData[@]}"
    chmod 755 '/etc/cron.daily/jenkins'

    # Install

    jenkinsMasterDownloadWARApp
    sleep 72
    jenkinsMasterDisplayVersion
    jenkinsMasterRefreshUpdateCenter
    jenkinsMasterUnlock
    restartService "${TOMCAT_SERVICE_NAME}"
    jenkinsMasterInstallPlugins
    jenkinsMasterUpdatePlugins
    jenkinsMasterSafeRestart

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/master.bash"
    source "${APP_FOLDER_PATH}/../libraries/app.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING MASTER JENKINS'

    installDependencies
    install
    installCleanUp
}

main "${@}"