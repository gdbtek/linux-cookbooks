#!/bin/bash -e

function main()
{
    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local -r hostName='nam.guru'
    local -r users="nam, ubuntu, $(whoami)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../libraries/util.bash"

    resetLogs

    "${appPath}/../../essential.bash" "${hostName}" "${users}"
    "${appPath}/../../../cookbooks/docker/recipes/install.bash"
    "${appPath}/../../../cookbooks/go-lang/recipes/install.bash"
    "${appPath}/../../../cookbooks/nginx/recipes/install.bash"
    "${appPath}/../../../cookbooks/node-js/recipes/install.bash"

    setupRepository
    cleanUpSystemFolders
    resetLogs
}

main "${@}"