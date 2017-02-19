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
    setupRepository
    updateRepositoryOnLogin "$(whoami)"

    if [[ "$(existUserLogin "${firstLoginUser}")" = 'true' ]]
    then
        addUserToSudoWithoutPassword "${firstLoginUser}"
        autoSudo "${firstLoginUser}" '.profile'
        addUserAuthorizedKey "${firstLoginUser}" "${firstLoginUser}" "$(cat "${appFolderPath}/../files/authorized_keys")"
    fi

    cleanUpSystemFolders
    resetLogs
}

main "${@}"