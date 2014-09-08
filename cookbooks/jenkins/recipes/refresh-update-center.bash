#!/bin/bash -e

function update()
{
    local updateInfo="$(getRemoteFileContent "${jenkinsUpdateCenterURL}")"
    updateInfo="$(echo "${updateInfo}" | sed '1d;$d')"

    checkValidJSONContent "${updateInfo}"

    # Update JSON

    local jsonFilePath="${jenkinsHomeFolder}/.jenkins/updates/default.json"

    checkFileExist "${jsonFilePath}"
    echo "${updateInfo}" > "${jsonFilePath}"
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