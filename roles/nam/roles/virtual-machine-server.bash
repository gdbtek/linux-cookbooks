#!/bin/bash -e

function main()
{
    local -r firstLoginUser='nam'

    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../libraries/app.bash"

    "$(dirname "${BASH_SOURCE[0]}")/../../../cookbooks/jq/recipes/install.bash"
    "$(dirname "${BASH_SOURCE[0]}")/../../../cookbooks/ps1/recipes/install.bash" --users "${firstLoginUser}, $(whoami)"
    "$(dirname "${BASH_SOURCE[0]}")/../../../cookbooks/ssh/recipes/install.bash"

    runUpgrade
    setupRepository
    updateRepositoryOnLogin "$(whoami)"

    if [[ "$(existUserLogin "${firstLoginUser}")" = 'true' ]]
    then
        addUserToSudoWithoutPassword "${firstLoginUser}"
        autoSudo "${firstLoginUser}" "$(basename "$(getProfileFilePath "${firstLoginUser}")")"
    fi

    cleanUpSystemFolders
    resetLogs
    postUpMessage
}

main "${@}"