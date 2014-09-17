#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
source "$(dirname "${BASH_SOURCE[0]}")/../attributes/master.bash"

function jenkinsMasterDownloadWARApp()
{
    local appName="$(getFileName "${jenkinsDownloadURL}")"
    local temporaryFile="$(getTemporaryFile)"

    checkNonEmptyString "${appName}"
    checkExistFile "${temporaryFile}"
    checkExistURL "${jenkinsDownloadURL}"

    debug "\nDownloading '${jenkinsDownloadURL}' to '${temporaryFile}'"
    curl -L "${jenkinsDownloadURL}" -o "${temporaryFile}"
    chown "${jenkinsUserName}:${jenkinsGroupName}" "${temporaryFile}"
    mv "${temporaryFile}" "${jenkinsTomcatInstallFolder}/webapps/${appName}.war"
    sleep 75
}