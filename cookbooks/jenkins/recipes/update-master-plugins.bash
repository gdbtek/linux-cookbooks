#!/bin/bash -e

function update()
{
    local appName="$(getFileName "${jenkinsDownloadURL}")"
    local jenkinsCLIPath="${jenkinsTomcatInstallFolder}/webapps/${appName}/WEB-INF/jenkins-cli.jar"
    local jenkinsAppURL="http://127.0.0.1:${jenkinsTomcatHTTPPort}/${appName}"

    checkExistFile "${jenkinsCLIPath}"
    checkExistURL "${jenkinsAppURL}"

    "${appPath}/refresh-master-update-center.bash"

    local updateList="$(java -jar "${jenkinsCLIPath}" -s "${jenkinsAppURL}" list-plugins | grep ')$' | awk '{ print $1 }' | sort -f)"

    "${appPath}/install-master-plugins.bash" ${updateList}
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