#!/bin/bash -e

function main()
{
    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local -r firstLoginUser='nam'

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../libraries/util.bash"

    "${appPath}/../../../cookbooks/jq/recipes/install.bash"
    "${appPath}/../../../cookbooks/ps1/recipes/install.bash" --users "${firstLoginUser}, $(whoami)"
    "${appPath}/../../../cookbooks/ssh/recipes/install.bash"

    runAptGetUpgrade

    addUserToSudoWithoutPassword "${firstLoginUser}"
    autoSudo "${firstLoginUser}" '.profile'

    setupRepository
    updateRepositoryOnLogin "$(whoami)"

    addUserAuthorizedKey "${firstLoginUser}" "${firstLoginUser}" "$(cat "${appPath}/../files/default/authorized_keys")"

    cleanUpSystemFolders
    resetLogs
}

main "${@}"