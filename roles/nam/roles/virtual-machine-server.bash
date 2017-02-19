#!/bin/bash -e

function main()
{
    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local -r firstLoginUser='nam'

    source "${appFolderPath}/../../../libraries/util.bash"
    source "${appFolderPath}/../libraries/app.bash"

    "${appFolderPath}/../../../cookbooks/jdk/recipes/install.bash"
    "${appFolderPath}/../../../cookbooks/jq/recipes/install.bash"
    "${appFolderPath}/../../../cookbooks/ps1/recipes/install.bash" --users "${firstLoginUser}, $(whoami)"
    "${appFolderPath}/../../../cookbooks/ssh/recipes/install.bash"

    runAptGetUpgrade

    addUserToSudoWithoutPassword "${firstLoginUser}"

    if [[ "$(existUserLogin "${firstLoginUser}")" = 'true' ]]
    then
        autoSudo "${firstLoginUser}" '.profile'
    fi

    setupRepository
    updateRepositoryOnLogin "$(whoami)"

    addUserAuthorizedKey "${firstLoginUser}" "${firstLoginUser}" "$(cat "${appFolderPath}/../files/authorized_keys")"

    cleanUpSystemFolders
    resetLogs
}

main "${@}"