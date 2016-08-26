#!/bin/bash -e

function main()
{
    # Load Libraries

    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../../../../../libraries/util.bash"
    source "${appFolderPath}/../../../../../libraries/util.bash"

    # Clean Up

    resetLogs

    # Install Apps

    "${appFolderPath}/../../../../../../essential.bash" 'selenium-hub' 'centos,root,ubuntu'
    "${appFolderPath}/../../../../../../../cookbooks/selenium-server/recipes/install-hub.bash"

    # Clean Up

    cleanUpSystemFolders
    cleanUpMess
}

main "${@}"