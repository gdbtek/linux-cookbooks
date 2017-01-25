#!/bin/bash -e

function safeRestart()
{
    umask '0022'

    local -r appName="$(getFileName "${JENKINS_DOWNLOAD_URL}")"
    local -r jenkinsCLIPath="${JENKINS_TOMCAT_INSTALL_FOLDER_PATH}/webapps/${appName}/WEB-INF/jenkins-cli.jar"
    local -r jenkinsAppURL="http://127.0.0.1:${JENKINS_TOMCAT_HTTP_PORT}/${appName}"

    checkNonEmptyString "${appName}"
    checkExistFile "${jenkinsCLIPath}"
    checkExistURL "${jenkinsAppURL}"

    java -jar "${jenkinsCLIPath}" -s "${jenkinsAppURL}" safe-restart

    umask '0077'
}

function main()
{
    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../libraries/util.bash"
    source "${appFolderPath}/../attributes/master.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'SAFE-RESTARTING MASTER JENKINS'

    safeRestart
    installCleanUp
}

main "${@}"