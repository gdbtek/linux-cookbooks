#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
source "$(dirname "${BASH_SOURCE[0]}")/../attributes/master.bash"

function jenkinsMasterWARAppCleanUp()
{
    local appName="$(getFileName "${jenkinsDownloadURL}")"

    checkNonEmptyString "${appName}"

    rm -f -r "${jenkinsTomcatInstallFolder}/webapps/${appName}.war" \
             "${jenkinsTomcatInstallFolder}/webapps/${appName}"
}

function jenkinsMasterDownloadWARApp()
{
    local appName="$(getFileName "${jenkinsDownloadURL}")"
    local temporaryFile="$(getTemporaryFile)"

    checkNonEmptyString "${appName}"
    checkExistFile "${temporaryFile}"
    checkExistFolder "${jenkinsTomcatInstallFolder}/webapps"

    downloadFile "${jenkinsDownloadURL}" "${temporaryFile}" 'true'
    chown "${jenkinsUserName}:${jenkinsGroupName}" "${temporaryFile}"
    mv "${temporaryFile}" "${jenkinsTomcatInstallFolder}/webapps/${appName}.war"
    sleep 75
}

function jenkinsMasterDisplayVersion()
{
    local appName="$(getFileName "${jenkinsDownloadURL}")"
    local jenkinsCLIPath="${jenkinsTomcatInstallFolder}/webapps/${appName}/WEB-INF/jenkins-cli.jar"

    checkNonEmptyString "${appName}"
    checkExistFile "${jenkinsCLIPath}"

    info "\nVersion: $('java' -jar "${jenkinsCLIPath}" \
                              -s "http://127.0.0.1:${jenkinsTomcatHTTPPort}/${appName}" \
                              version)"
}

function jenkinsMasterRefreshUpdateCenter()
{
    checkTrueFalseString "${jenkinsUpdateAllPlugins}"

    "$(dirname "${BASH_SOURCE[0]}")/../recipes/refresh-master-update-center.bash"
}

function jenkinsMasterUpdatePlugins()
{
    if [[ "${jenkinsUpdateAllPlugins}" = 'true' ]]
    then
        "$(dirname "${BASH_SOURCE[0]}")/../recipes/update-master-plugins.bash"
    fi
}

function jenkinsMasterInstallPlugins()
{
    if [[ ${#jenkinsInstallPlugins[@]} -gt 0 ]]
    then
        "$(dirname "${BASH_SOURCE[0]}")/../recipes/install-master-plugins.bash" "${jenkinsInstallPlugins[@]}"
    fi
}

function jenkinsMasterSafeRestart()
{
    if [[ ${#jenkinsInstallPlugins[@]} -gt 0 || "${jenkinsUpdateAllPlugins}" = 'true' ]]
    then
        "$(dirname "${BASH_SOURCE[0]}")/../recipes/safe-restart-master.bash"
    fi
}