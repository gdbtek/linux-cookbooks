#!/bin/bash -e

function refreshUpdateCenter()
{
    # Validate Jenkins Config Folder

    if [[ "$(isEmptyString "${JENKINS_INSTALL_FOLDER}")" = 'true' ]]
    then
        JENKINS_INSTALL_FOLDER="$(getUserHomeFolder "${JENKINS_USER_NAME}")/.jenkins"
    fi

    checkExistFolder "${JENKINS_INSTALL_FOLDER}"

    # Validate JSON Content

    local updateInfo="$(getRemoteFileContent "${JENKINS_UPDATE_CENTER_URL}")"
    updateInfo="$(sed '1d;$d' <<< "${updateInfo}")"

    checkValidJSONContent "${updateInfo}"

    # Update JSON File

    local -r jsonFilePath="${JENKINS_INSTALL_FOLDER}/updates/default.json"
    local -r updateFolderPath="$(dirname "${jsonFilePath}")"

    mkdir -p "${updateFolderPath}"
    echo "${updateInfo}" > "${jsonFilePath}"
    chown -R "${JENKINS_USER_NAME}:${JENKINS_GROUP_NAME}" "${updateFolderPath}"
    info "Updated '${jsonFilePath}'"
}

function main()
{
    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/master.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'REFRESHING MASTER UPDATE CENTER JENKINS'

    refreshUpdateCenter
    installCleanUp
}

main "${@}"