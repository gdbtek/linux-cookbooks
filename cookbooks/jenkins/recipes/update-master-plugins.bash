#!/bin/bash -e

function updatePlugins()
{
    umask '0022'

    local -r appName="$(getFileName "${JENKINS_DOWNLOAD_URL}")"
    local -r jenkinsCLIPath="${JENKINS_TOMCAT_INSTALL_FOLDER_PATH}/webapps/${appName}/WEB-INF/jenkins-cli.jar"
    local -r jenkinsAppURL="http://127.0.0.1:${JENKINS_TOMCAT_HTTP_PORT}/${appName}"

    checkNonEmptyString "${appName}"
    checkExistFile "${jenkinsCLIPath}"
    checkExistURL "${jenkinsAppURL}"

    local -r updateList=("$(java -jar "${jenkinsCLIPath}" -s "${jenkinsAppURL}" list-plugins | grep ')$' | awk '{ print $1 }' | sort -f)")

    "${APP_FOLDER_PATH}/install-master-plugins.bash" "${updateList[@]}"

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/master.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    updatePlugins
    installCleanUp
}

main "${@}"