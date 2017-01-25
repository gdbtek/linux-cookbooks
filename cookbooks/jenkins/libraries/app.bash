#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
source "$(dirname "${BASH_SOURCE[0]}")/../attributes/master.bash"

function jenkinsMasterWARAppCleanUp()
{
    local -r appName="$(getFileName "${JENKINS_DOWNLOAD_URL}")"

    checkNonEmptyString "${appName}"

    rm -f -r "${JENKINS_TOMCAT_INSTALL_FOLDER_PATH}/webapps/${appName}.war" \
             "${JENKINS_TOMCAT_INSTALL_FOLDER_PATH}/webapps/${appName}"
}

function jenkinsMasterDownloadWARApp()
{
    local -r appName="$(getFileName "${JENKINS_DOWNLOAD_URL}")"
    local -r temporaryFile="$(getTemporaryFile)"

    checkNonEmptyString "${appName}"
    checkExistFile "${temporaryFile}"
    checkExistFolder "${JENKINS_TOMCAT_INSTALL_FOLDER_PATH}/webapps"

    downloadFile "${JENKINS_DOWNLOAD_URL}" "${temporaryFile}" 'true'
    chown "${JENKINS_USER_NAME}:${JENKINS_GROUP_NAME}" "${temporaryFile}"
    mv "${temporaryFile}" "${JENKINS_TOMCAT_INSTALL_FOLDER_PATH}/webapps/${appName}.war"
}

function jenkinsMasterDisplayVersion()
{
    local -r appName="$(getFileName "${JENKINS_DOWNLOAD_URL}")"
    local -r jenkinsCLIPath="${JENKINS_TOMCAT_INSTALL_FOLDER_PATH}/webapps/${appName}/WEB-INF/jenkins-cli.jar"

    checkNonEmptyString "${appName}"
    checkExistFile "${jenkinsCLIPath}"

    info "\nVersion : $(
        java \
            -jar "${jenkinsCLIPath}" \
            -s "http://127.0.0.1:${JENKINS_TOMCAT_HTTP_PORT}/${appName}" \
            -version
    )"
}

function jenkinsMasterRefreshUpdateCenter()
{
    checkTrueFalseString "${JENKINS_UPDATE_ALL_PLUGINS}"

    "$(dirname "${BASH_SOURCE[0]}")/../recipes/refresh-master-update-center.bash"
}

function jenkinsMasterUpdatePlugins()
{
    if [[ "${JENKINS_UPDATE_ALL_PLUGINS}" = 'true' ]]
    then
        "$(dirname "${BASH_SOURCE[0]}")/../recipes/update-master-plugins.bash"
    fi
}

function jenkinsMasterInstallPlugins()
{
    if [[ "${#JENKINS_INSTALL_PLUGINS[@]}" -gt '0' ]]
    then
        "$(dirname "${BASH_SOURCE[0]}")/../recipes/install-master-plugins.bash" "${JENKINS_INSTALL_PLUGINS[@]}"
    fi
}

function jenkinsMasterSafeRestart()
{
    if [[ "${#JENKINS_INSTALL_PLUGINS[@]}" -gt '0' || "${JENKINS_UPDATE_ALL_PLUGINS}" = 'true' ]]
    then
        "$(dirname "${BASH_SOURCE[0]}")/../recipes/safe-restart-master.bash"
    fi
}

function jenkinsMasterUnlock()
{
    local -r configData=('<useSecurity>true</useSecurity>' '<useSecurity>false</useSecurity>')

    createFileFromTemplate "${JENKINS_INSTALL_FOLDER_PATH}/config.xml" "${JENKINS_INSTALL_FOLDER_PATH}/config.xml" "${configData[@]}"
    echo '2.0' > "${JENKINS_INSTALL_FOLDER_PATH}/jenkins.install.InstallUtil.lastExecVersion"
}