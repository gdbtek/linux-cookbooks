#!/bin/bash -e

function update()
{
    # Validate Jenkins Config Folder

    if [[ "$(isEmptyString "${jenkinsHomeFolder}")" = 'true' ]]
    then
        jenkinsHomeFolder="$(getUserHomeFolder "${jenkinsUserName}")/.jenkins"
    fi

    checkExistFolder "${jenkinsHomeFolder}"

    # Validate JSON Content

    local updateInfo="$(getRemoteFileContent "${jenkinsUpdateCenterURL}")"
    updateInfo="$(echo "${updateInfo}" | sed '1d;$d')"

    checkValidJSONContent "${updateInfo}"

    # Update JSON File

    local jsonFilePath="${jenkinsHomeFolder}/updates/default.json"
    local updateFolderPath="$(dirname "${jsonFilePath}")"

    mkdir -p "${updateFolderPath}"
    echo "${updateInfo}" > "${jsonFilePath}"
    chown -R "${jenkinsUserName}:${jenkinsGroupName}" "${updateFolderPath}"
    info "Updated '${jsonFilePath}'"
}

function main()
{
    local appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../lib/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'REFRESHING UPDATE CENTER JENKINS'

    update
    installCleanUp
}

main "${@}"