#!/bin/bash -e

function main()
{
    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../libraries/util.bash"

    resetLogs

    "${appPath}/../../../cookbooks/jq/recipes/install.bash"
    "${appPath}/../../../cookbooks/ps1/recipes/install.bash" --users "nam, $(whoami)"
    "${appPath}/../../../cookbooks/ssh/recipes/install.bash"

    runAptGetUpgrade
    addUserToSudoWithoutPassword 'nam'
    autoSudo 'nam' '.profile'
    setupRepository
    updateRepositoryOnLogin "$(whoami)"
    cleanUpSystemFolders
}

main "${@}"