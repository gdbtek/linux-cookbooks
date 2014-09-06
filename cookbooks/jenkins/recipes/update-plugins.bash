#!/bin/bash -e

function update()
{
    local appName="$(getFileName "${jenkinsDownloadURL}")"
    local jenkinsCLIPath="${jenkinsTomcatFolder}/webapps/${appName}/WEB-INF/jenkins-cli.jar"
    local jenkinsAppURL="http://127.0.0.1:${jenkinsTomcatHTTPPort}/${appName}"
    local updateList="$(java -jar "${jenkinsCLIPath}" -s "${jenkinsAppURL}" list-plugins | grep ')$' | awk '{ print $1 }')"

    if [[ "$(isEmptyString "${updateList}")" = 'false' ]]
    then
        java -jar "${jenkinsCLIPath}" -s "${jenkinsAppURL}" install-plugin ${updateList}
        java -jar "${jenkinsCLIPath}" -s "${jenkinsAppURL}" safe-restart
    else
        info "No updates available!"
    fi
}

function main()
{
    local appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../lib/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'UPDATING PLUGINS JENKINS'

    update
    installCleanUp
}

main "${@}"