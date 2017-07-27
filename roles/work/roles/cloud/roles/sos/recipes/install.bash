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
    resetLogs

    # Install Apps

    if [[ "$(isUbuntuDistributor)" = 'true' ]]
    then
        apt-get update -m
    fi

    "${appFolderPath}/../../../../../../essential.bash" 'sos' "$(arrayToString "${CLOUD_USERS[@]}")"
    "${appFolderPath}/../../../../../../../cookbooks/aws-cli/recipes/install.bash"
    "${appFolderPath}/../../../../../../../cookbooks/chef-client/recipes/install.bash"

    # Config SSH and GIT

    configUsersSSH "${CLOUD_USERS[@]}"

    configUserGIT "$(whoami)" "${SOS_GIT_USER_NAME}" "${SOS_GIT_USER_EMAIL}"
    generateUserSSHKey "$(whoami)"

    # Clean Up

    cleanUpSystemFolders
    cleanUpMess

    # Display Notice

    displayNotice "$(whoami)" 'false'
}

main "${@}"