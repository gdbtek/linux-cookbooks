#!/bin/bash -e

function main()
{
    local -r firstLoginUser='nam'

    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../libraries/app.bash"

    "$(dirname "${BASH_SOURCE[0]}")/../../../cookbooks/essential/recipes/install.bash"
    "$(dirname "${BASH_SOURCE[0]}")/../../../cookbooks/jq/recipes/install.bash"
    "$(dirname "${BASH_SOURCE[0]}")/../../../cookbooks/ps1/recipes/install.bash"
    "$(dirname "${BASH_SOURCE[0]}")/../../../cookbooks/ps1/recipes/install.bash" --profile-file-name '.bashrc' --users "${firstLoginUser}"
    "$(dirname "${BASH_SOURCE[0]}")/../../../cookbooks/ssh/recipes/install.bash"
    "$(dirname "${BASH_SOURCE[0]}")/../../../cookbooks/vim/recipes/install.bash"
    "$(dirname "${BASH_SOURCE[0]}")/../../../cookbooks/vmware-tools/recipes/install.bash"

    setupRepository
    updateRepositoryOnLogin "$(whoami)"

    if [[ "$(existUserLogin "${firstLoginUser}")" = 'true' ]]
    then
        addUserToSudoWithoutPassword "${firstLoginUser}"
        autoSudo "${firstLoginUser}" '.bashrc'
    fi

    cleanUpSystemFolders
    resetLogs
    postUpMessage
}

main "${@}"