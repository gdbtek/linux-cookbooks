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

    installPackage 'libkrb5-dev' 'krb5-devel'

    "${appFolderPath}/../../../../../../essential.bash" 'build-tracker' "$(arrayToString "${CLOUD_USERS[@]}")"
    "${appFolderPath}/../../../../../../../cookbooks/mongodb/recipes/install.bash"
    "${appFolderPath}/../../../../../../../cookbooks/node-js/recipes/install.bash" "${CLOUD_NODE_JS_VERSION}" "${CLOUD_NODE_JS_INSTALL_FOLDER_PATH}"

    # Config SSH and GIT

    configUsersSSH "${CLOUD_USERS[@]}"
    configUserGIT "$(whoami)" "${CLOUD_GIT_USER_NAME}" "${CLOUD_GIT_USER_EMAIL}"
    generateUserSSHKey "$(whoami)"

    # Clean Up

    cleanUpSystemFolders
    cleanUpMess

    # Display Notice

    displayNotice "$(whoami)" 'false'
}

main "${@}"