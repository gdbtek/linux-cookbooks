#!/bin/bash -e

function main()
{
    local appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../libraries/util.bash"

    # "${appPath}/../../cookbooks/apt-source/recipes/install.bash"

    "${appPath}/../essential.bash"

    "${appPath}/../../cookbooks/ufw/recipes/install.bash"
    "${appPath}/../../cookbooks/node-js/recipes/install.bash"
    "${appPath}/../../cookbooks/nginx/recipes/install.bash"
    "${appPath}/../../cookbooks/redis/recipes/install.bash"
    "${appPath}/../../cookbooks/mongodb/recipes/install.bash"
    "${appPath}/../../cookbooks/jdk/recipes/install.bash"
    "${appPath}/../../cookbooks/ps1/recipes/install.bash" --host-name 'nam.guru' --users 'nam, ubuntu'

    cleanUpSystemFolders
}

main "${@}"