#!/bin/bash -e

function install()
{
    local pluginList="${@}"

    if [[ "$(isEmptyString "${pluginList}")" = 'false' ]]
    then
        local appName="$(getFileName "${jenkinsDownloadURL}")"
        local jenkinsCLIPath="${jenkinsTomcatFolder}/webapps/${appName}/WEB-INF/jenkins-cli.jar"
        local jenkinsAppURL="http://127.0.0.1:${jenkinsTomcatHTTPPort}/${appName}"

        checkExistFile "${jenkinsCLIPath}"
        checkExistURL "${jenkinsAppURL}"

        "${appPath}/refresh-update-center.bash"
        echo

        java -jar "${jenkinsCLIPath}" -s "${jenkinsAppURL}" install-plugin ${pluginList}
        java -jar "${jenkinsCLIPath}" -s "${jenkinsAppURL}" safe-restart

        sleep 120
    else
        info "No installs/updates available!"
    fi
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../lib/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING PLUGINS JENKINS'

    install "${@}"
    installCleanUp
}

main "${@}"