#!/bin/bash -e

function main()
{
    local appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../libraries/util.bash"

    "${appPath}/../../../cookbooks/ps1/recipes/install.bash" --users "nam, $(whoami)"

    runAptGetUpgrade
    addUserToSudoWithoutPassword 'nam'
    autoSudo 'nam' '.profile'
    setupRepository
    updateRepositoryOnLogin "$(whoami)"
    cleanUpSystemFolders
}

main "${@}"