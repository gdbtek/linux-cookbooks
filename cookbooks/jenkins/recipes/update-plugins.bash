#!/bin/bash -e

function update()
{
    "${appPath}/refresh-update-center.bash"

    local appName="$(getFileName "${jenkinsDownloadURL}")"
    local jenkinsCLIPath="${jenkinsTomcatFolder}/webapps/${appName}/WEB-INF/jenkins-cli.jar"
    local jenkinsAppURL="http://127.0.0.1:${jenkinsTomcatHTTPPort}/${appName}"

    checkExistFile "${jenkinsCLIPath}"
    checkExistURL "${jenkinsAppURL}"

    local updateList="$(java -jar "${jenkinsCLIPath}" -s "${jenkinsAppURL}" list-plugins | grep ')$' | awk '{ print $1 }')"

    "${appPath}/install-plugins.bash" ${updateList}
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../lib/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    update
    installCleanUp
}

main "${@}"