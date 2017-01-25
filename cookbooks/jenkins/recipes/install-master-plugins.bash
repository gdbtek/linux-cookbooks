#!/bin/bash -e

function install()
{
    local -r pluginList=($(sed -e 's/\n/ /g' <<< "${@}"))

    umask '0022'

    if [[ "${#pluginList[@]}" -gt '0' ]]
    then
        local -r appName="$(getFileName "${JENKINS_DOWNLOAD_URL}")"
        local -r jenkinsCLIPath="${JENKINS_TOMCAT_INSTALL_FOLDER_PATH}/webapps/${appName}/WEB-INF/jenkins-cli.jar"
        local -r jenkinsAppURL="http://127.0.0.1:${JENKINS_TOMCAT_HTTP_PORT}/${appName}"

        checkNonEmptyString "${appName}"
        checkExistFile "${jenkinsCLIPath}"
        sleep 75
        checkExistURL "${jenkinsAppURL}"

        java -jar "${jenkinsCLIPath}" -s "${jenkinsAppURL}" install-plugin "${pluginList[@]}"
    else
        info 'No installs/updates available'
    fi

    umask '0077'
}

function main()
{
    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../libraries/util.bash"
    source "${appFolderPath}/../attributes/master.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING MASTER PLUGINS JENKINS'

    install "${@}"
    installCleanUp
}

main "${@}"