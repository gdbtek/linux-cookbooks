#!/bin/bash -e

function update()
{
    # Validate JSON File Path

    local jsonFilePath="${jenkinsHomeFolder}/.jenkins/updates/default.json"

    checkExistFolder "$(dirname "${jsonFilePath}")"

    # Update JSON

    local updateInfo="$(getRemoteFileContent "${jenkinsUpdateCenterURL}")"
    updateInfo="$(echo "${updateInfo}" | sed '1d;$d')"

    checkValidJSONContent "${updateInfo}"

    echo "${updateInfo}" > "${jsonFilePath}"

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