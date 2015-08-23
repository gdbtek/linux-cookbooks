#!/bin/bash -e

function main()
{
    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local -r firstLoginUser='nam'
    local -r hostName='nam.guru'

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../libraries/util.bash"

    "${appPath}/../../essential.bash" "${hostName}" "${firstLoginUser}, $(whoami)"
    "${appPath}/../../../cookbooks/docker/recipes/install.bash"
    "${appPath}/../../../cookbooks/go-lang/recipes/install.bash"
    "${appPath}/../../../cookbooks/nginx/recipes/install.bash"
    "${appPath}/../../../cookbooks/node-js/recipes/install.bash"

    addUserToSudoWithoutPassword "${firstLoginUser}"
    autoSudo "${firstLoginUser}" '.bashrc'

    setupRepository
    updateRepositoryOnLogin "$(whoami)"

    addUserAuthorizedKey "${firstLoginUser}" "${firstLoginUser}" "$(cat "${appPath}/../files/default/authorized_keys")"

    cleanUpSystemFolders
    resetLogs
}

main "${@}"