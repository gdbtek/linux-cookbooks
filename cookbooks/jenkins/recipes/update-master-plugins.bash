#!/bin/bash -e

function updatePlugins()
{
    local -r appName="$(getFileName "${JENKINS_DOWNLOAD_URL}")"
    local -r jenkinsCLIPath="${JENKINS_TOMCAT_INSTALL_FOLDER}/webapps/${appName}/WEB-INF/jenkins-cli.jar"
    local -r jenkinsAppURL="http://127.0.0.1:${JENKINS_TOMCAT_HTTP_PORT}/${appName}"

    checkNonEmptyString "${appName}"
    checkExistFile "${jenkinsCLIPath}"
    checkExistURL "${jenkinsAppURL}"

    local -r updateList=("$(java -jar "${jenkinsCLIPath}" -s "${jenkinsAppURL}" list-plugins | grep ')$' | awk '{ print $1 }' | sort -f)")

    "${appFolderPath}/install-master-plugins.bash" "${updateList[@]}"
}

function main()
{
    appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../libraries/util.bash"
    source "${appFolderPath}/../attributes/master.bash"

    checkRequireSystem
    checkRequireRootUser

    updatePlugins
    installCleanUp
}

main "${@}"