#!/bin/bash -e

function main()
{
    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local -r firstLoginUser='nam'

    source "${appFolderPath}/../../../libraries/util.bash"
    source "${appFolderPath}/../libraries/app.bash"

    "${appFolderPath}/../../../cookbooks/essential/recipes/install.bash"
    "${appFolderPath}/../../../cookbooks/jq/recipes/install.bash"
    "${appFolderPath}/../../../cookbooks/ps1/recipes/install.bash"
    "${appFolderPath}/../../../cookbooks/ps1/recipes/install.bash" --profile-file-name '.bashrc' --users "${firstLoginUser}"
    "${appFolderPath}/../../../cookbooks/ssh/recipes/install.bash"
    "${appFolderPath}/../../../cookbooks/vim/recipes/install.bash"
    "${appFolderPath}/../../../cookbooks/vmware-tools/recipes/install.bash"

    setupRepository
    updateRepositoryOnLogin "$(whoami)"

    if [[ "$(existUserLogin "${firstLoginUser}")" = 'true' ]]
    then
        addUserToSudoWithoutPassword "${firstLoginUser}"
        autoSudo "${firstLoginUser}" '.bashrc'
        addUserAuthorizedKey "${firstLoginUser}" "${firstLoginUser}" "$(cat "${appFolderPath}/../files/authorized_keys")"
    fi

    cleanUpSystemFolders
    resetLogs
    postUpMessage
}

main "${@}"