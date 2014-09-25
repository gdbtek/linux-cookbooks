#!/bin/bash -e

function updatePlugins()
{
    local appName="$(getFileName "${jenkinsDownloadURL}")"
    local jenkinsCLIPath="${jenkinsTomcatInstallFolder}/webapps/${appName}/WEB-INF/jenkins-cli.jar"
    local jenkinsAppURL="http://127.0.0.1:${jenkinsTomcatHTTPPort}/${appName}"

    checkNonEmptyString "${appName}"
    checkExistFile "${jenkinsCLIPath}"
    checkExistURL "${jenkinsAppURL}"

    local updateList=("$(java -jar "${jenkinsCLIPath}" -s "${jenkinsAppURL}" list-plugins | grep ')$' | awk '{ print $1 }' | sort -f)")

    "${appPath}/install-master-plugins.bash" "${updateList[@]}"
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/master.bash"

    checkRequireSystem
    checkRequireRootUser

    updatePlugins
    installCleanUp
}

main "${@}"