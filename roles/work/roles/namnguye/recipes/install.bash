#!/bin/bash -e

function main()
{
    # Load Libraries

    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../../../libraries/util.bash"
    source "${appFolderPath}/../../../libraries/app.bash"
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

    "${appFolderPath}/../../../../essential.bash" 'nam' "$(arrayToString "${CLOUD_USERS[@]}")"
    "${appFolderPath}/../../../../../cookbooks/aws-cli/recipes/install.bash"
    "${appFolderPath}/../../../../../cookbooks/chef-client/recipes/install.bash"
    "${appFolderPath}/../../../../../cookbooks/docker/recipes/install.bash" || true
    "${appFolderPath}/../../../../../cookbooks/foodcritic/recipes/install.bash"
    "${appFolderPath}/../../../../../cookbooks/go-lang/recipes/install.bash"
    "${appFolderPath}/../../../../../cookbooks/node-js/recipes/install.bash" "${NAMNGUYE_NODE_JS_VERSION}" "${NAMNGUYE_NODE_JS_INSTALL_FOLDER_PATH}"
    "${appFolderPath}/../../../../../cookbooks/packer/recipes/install.bash"
    "${appFolderPath}/../../../../../cookbooks/porter/recipes/install.bash"
    "${appFolderPath}/../../../../../cookbooks/shell-check/recipes/install.bash"
    "${appFolderPath}/../../../../../cookbooks/terraform/recipes/install.bash"

    # Config SSH and GIT

    configUsersSSH "${CLOUD_USERS[@]}"

    configUserGIT "$(whoami)" "${NAMNGUYE_GIT_USER_NAME}" "${NAMNGUYE_GIT_USER_EMAIL}"
    generateUserSSHKey "$(whoami)"

    # Clean Up

    cleanUpSystemFolders
    cleanUpMess

    # Display Notice

    displayNotice "$(whoami)" 'false'

    # Finish

    postUpMessage
}

main "${@}"