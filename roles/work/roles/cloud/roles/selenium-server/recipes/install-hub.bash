#!/bin/bash -e

function main()
{
    # Load Libraries

    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../../../../../libraries/util.bash"
    source "${appFolderPath}/../../../../../libraries/util.bash"

    # Clean Up

    remountTMP
    resetLogs

    # Install Apps

    if [[ "$(isUbuntuDistributor)" = 'true' ]]
    then
        apt-get update -m
    fi

    "${appFolderPath}/../../../../../../essential.bash" 'selenium-hub' "centos, $(whoami), root, ubuntu"
    "${appFolderPath}/../../../../../../../cookbooks/data-dog/recipes/install.bash"
    "${appFolderPath}/../../../../../../../cookbooks/selenium-server/recipes/install-hub.bash"

    # Clean Up

    cleanUpSystemFolders
    cleanUpMess
}

main "${@}"