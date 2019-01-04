#!/bin/bash -e

function main()
{
    # Load Libraries

    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../../../../../libraries/util.bash"
    source "${appFolderPath}/../../../../../libraries/app.bash"
    source "${appFolderPath}/../attributes/default.bash"

    # Clean Up

    addSwapSpace
    remountTMP
    redirectJDKTMPDir
    resetLogs

    # Install Apps

    if [[ "$(isUbuntuDistributor)" = 'true' ]]
    then
        apt-get update -m
    fi

    "${appFolderPath}/../../../../../../essential.bash" 'selenium-hub' "$(arrayToString "${CLOUD_USERS[@]}")"
    "${appFolderPath}/../../../../../../../cookbooks/selenium-server/recipes/install-hub.bash"

    # Config SSH

    configUsersSSH "${CLOUD_USERS[@]}"

    # Clean Up

    cleanUpSystemFolders
    cleanUpMess

    # Finish

    postUpMessage
}

main "${@}"