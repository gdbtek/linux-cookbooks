#!/bin/bash -e

function main()
{
    local appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../libraries/util.bash"

    "${appPath}/../../../cookbooks/essential/recipes/install.bash"
    "${appPath}/../../../cookbooks/ps1/recipes/install.bash"
    "${appPath}/../../../cookbooks/ps1/recipes/install.bash" --profile-file-name '.bashrc' --users 'nam'
    "${appPath}/../../../cookbooks/vim/recipes/install.bash"

    setupGIT
    cleanUpSystemFolders
}

main "${@}"