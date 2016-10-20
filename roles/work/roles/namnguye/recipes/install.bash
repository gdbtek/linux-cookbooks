#!/bin/bash -e

function main()
{
    # Load Libraries

    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../../../libraries/util.bash"
    source "${appFolderPath}/../../../libraries/util.bash"
    source "${appFolderPath}/../attributes/default.bash"

    # Clean Up

    remountTMP
    resetLogs

    # Install Apps

    if [[ "$(isUbuntuDistributor)" = 'true' ]]
    then
        apt-get update -m
    fi

    "${appFolderPath}/../../../../essential.bash" 'nam'
    "${appFolderPath}/../../../../../cookbooks/aws-cli/recipes/install.bash"
    "${appFolderPath}/../../../../../cookbooks/chef/recipes/install.bash"
    "${appFolderPath}/../../../../../cookbooks/foodcritic/recipes/install.bash"
    "${appFolderPath}/../../../../../cookbooks/go-lang/recipes/install.bash"
    "${appFolderPath}/../../../../../cookbooks/node-js/recipes/install.bash" "${NAMNGUYE_NODE_JS_VERSION}" "${NAMNGUYE_NODE_JS_INSTALL_FOLDER}"
    "${appFolderPath}/../../../../../cookbooks/packer/recipes/install.bash"
    "${appFolderPath}/../../../../../cookbooks/shell-check/recipes/install.bash"

    # Config SSH and GIT

    configUsersSSH "${CLOUD_USERS[@]}"

    configUserGIT "$(whoami)" "${NAMNGUYE_GIT_USER_NAME}" "${NAMNGUYE_GIT_USER_EMAIL}"
    generateUserSSHKey "$(whoami)"

    # Clean Up

    cleanUpSystemFolders
    cleanUpMess

    # Display Notice

    displayNotice "$(whoami)"
}

main "${@}"