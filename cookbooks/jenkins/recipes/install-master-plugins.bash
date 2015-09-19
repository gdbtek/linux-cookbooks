#!/bin/bash -e

function install()
{
    local -r pluginList=($(sed -e 's/\n/ /g' <<< "${@}"))

    if [[ "${#pluginList[@]}" -gt '0' ]]
    then
        local -r appName="$(getFileName "${JENKINS_DOWNLOAD_URL}")"
        local -r jenkinsCLIPath="${JENKINS_TOMCAT_INSTALL_FOLDER}/webapps/${appName}/WEB-INF/jenkins-cli.jar"
        local -r jenkinsAppURL="http://127.0.0.1:${JENKINS_TOMCAT_HTTP_PORT}/${appName}"

        checkNonEmptyString "${appName}"
        checkExistFile "${jenkinsCLIPath}"
        checkExistURL "${jenkinsAppURL}"

        java -jar "${jenkinsCLIPath}" -s "${jenkinsAppURL}" install-plugin "${pluginList[@]}"
    else
        info "No installs/updates available"
    fi
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # shellcheck source=/dev/null
    source "${appPath}/../../../libraries/util.bash"
    # shellcheck source=/dev/null
    source "${appPath}/../attributes/master.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING MASTER PLUGINS JENKINS'

    install "${@}"
    installCleanUp
}

main "${@}"