#!/bin/bash -e

function main()
{
    local appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local hostName='nam.guru'
    local users="nam, ubuntu, $(whoami)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../libraries/util.bash"

    # "${appPath}/../../../cookbooks/apt-source/recipes/install.bash"

    "${appPath}/../../essential.bash" "${hostName}" "${users}"

    "${appPath}/../../../cookbooks/ufw/recipes/install.bash"
    "${appPath}/../../../cookbooks/node-js/recipes/install.bash"
    "${appPath}/../../../cookbooks/nginx/recipes/install.bash"
    "${appPath}/../../../cookbooks/redis/recipes/install.bash"
    "${appPath}/../../../cookbooks/mongodb/recipes/install.bash"
    "${appPath}/../../../cookbooks/jdk/recipes/install.bash"
    "${appPath}/../../../cookbooks/ps1/recipes/install.bash" --host-name "${hostName}" --users "${users}"

    setupGIT
    cleanUpSystemFolders
}

main "${@}"