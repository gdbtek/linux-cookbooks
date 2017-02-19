#!/bin/bash -e

function main()
{
    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local -r firstLoginUser='nam'
    local -r hostName='nam.guru'

    source "${appFolderPath}/../../../libraries/util.bash"
    source "${appFolderPath}/../libraries/app.bash"

    "${appFolderPath}/../../essential.bash" "${hostName}" "${firstLoginUser}, $(whoami)"
    "${appFolderPath}/../../../cookbooks/docker/recipes/install.bash"
    "${appFolderPath}/../../../cookbooks/go-lang/recipes/install.bash"
    "${appFolderPath}/../../../cookbooks/nginx/recipes/install-from-source.bash"
    "${appFolderPath}/../../../cookbooks/node-js/recipes/install.bash"

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
}

main "${@}"