#!/bin/bash -e

function refreshUpdateCenter()
{
    # Validate Jenkins Config Folder

    if [[ "$(isEmptyString "${jenkinsInstallFolder}")" = 'true' ]]
    then
        jenkinsInstallFolder="$(getUserHomeFolder "${jenkinsUserName}")/.jenkins"
    fi

    checkExistFolder "${jenkinsInstallFolder}"

    # Validate JSON Content

    local updateInfo="$(getRemoteFileContent "${jenkinsUpdateCenterURL}")"
    updateInfo="$(echo "${updateInfo}" | sed '1d;$d')"

    checkValidJSONContent "${updateInfo}"

    # Update JSON File

    local jsonFilePath="${jenkinsInstallFolder}/updates/default.json"
    local updateFolderPath="$(dirname "${jsonFilePath}")"

    mkdir -p "${updateFolderPath}"
    echo "${updateInfo}" > "${jsonFilePath}"
    chown -R "${jenkinsUserName}:${jenkinsGroupName}" "${updateFolderPath}"
    info "Updated '${jsonFilePath}'"
}

function main()
{
    local appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/master.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'REFRESHING MASTER UPDATE CENTER JENKINS'

    refreshUpdateCenter
    installCleanUp
}

main "${@}"