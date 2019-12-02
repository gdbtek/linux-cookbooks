#!/bin/bash -e

function installDependencies()
{
    # Groovy

    if [[ "$(existCommand 'groovy')" = 'false' || ! -d "${JENKINS_GROOVY_INSTALL_FOLDER_PATH}" ]]
    then
        "$(dirname "${BASH_SOURCE[0]}")/../../groovy/recipes/install.bash" "${JENKINS_GROOVY_INSTALL_FOLDER_PATH}"
    fi

    # Tomcat

    if [[ ! -f "${JENKINS_TOMCAT_INSTALL_FOLDER_PATH}/bin/catalina.sh" ]]
    then
        "$(dirname "${BASH_SOURCE[0]}")/../../tomcat/recipes/install.bash" "${JENKINS_TOMCAT_INSTALL_FOLDER_PATH}"
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

    createFileFromTemplate \
        "$(dirname "${BASH_SOURCE[0]}")/../templates/jenkins.sh.profile" \
        '/etc/profile.d/jenkins.sh' \
        '__INSTALL_FOLDER_PATH__' "${JENKINS_INSTALL_FOLDER_PATH}"

    # Config Cron

    createFileFromTemplate \
        "$(dirname "${BASH_SOURCE[0]}")/../templates/jenkins.cron" \
        '/etc/cron.daily/jenkins' \
        '__USER_NAME__' "${JENKINS_USER_NAME}" \
        '__GROUP_NAME__' "${JENKINS_GROUP_NAME}" \
        '__INSTALL_FOLDER_PATH__' "${JENKINS_INSTALL_FOLDER_PATH}"

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
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/master.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../libraries/app.bash"

    header 'INSTALLING MASTER JENKINS'

    checkRequireLinuxSystem
    checkRequireRootUser

    installDependencies
    install
    installCleanUp
}

main "${@}"