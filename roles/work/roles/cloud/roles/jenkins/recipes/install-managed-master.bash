#!/bin/bash -e

JENKINS_USER_NAME='jnknsprd'

function main()
{
    # Load Libraries

    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../../../../../libraries/util.bash"
    source "${appFolderPath}/../../../../../libraries/app.bash"
    source "${appFolderPath}/../attributes/master.bash"

    # Clean Up

    addSwapSpace
    remountTMP
    redirectJDKTMPDir
    resetLogs

    # Install Apps

    local -r hostName='jenkins-master'

    if [[ "$(isUbuntuDistributor)" = 'true' ]]
    then
        apt-get update -m
    fi

    "${appFolderPath}/../../../../../../essential.bash" "${hostName}" "$(arrayToString "${CLOUD_USERS[@]}")"
    "${appFolderPath}/../../../../../../../cookbooks/akamai-cli/recipes/install.bash"
    "${appFolderPath}/../../../../../../../cookbooks/maven/recipes/install.bash"
    "${appFolderPath}/../../../../../../../cookbooks/node-js/recipes/install.bash" "${CLOUD_JENKINS_NODE_JS_VERSION}" "${CLOUD_JENKINS_NODE_JS_INSTALL_FOLDER_PATH}"

    # Config SSH and GIT

    generateSSHPublicKeyFromPrivateKey "${JENKINS_USER_NAME}" 'users'

    # Clean Up

    cleanUpSystemFolders
    cleanUpMess

    # Display Notice

    displayNotice "${JENKINS_USER_NAME}" 'true'

    # Finish

    postUpMessage
}

main "${@}"