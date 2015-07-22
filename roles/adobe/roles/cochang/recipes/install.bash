#!/bin/bash -e

function main()
{
    # Load Libraries

    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../../../cookbooks/mount-hd/attributes/default.bash"
    source "${appPath}/../../../../../libraries/util.bash"
    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    # Clean Up

    resetLogs

    # Extend HD

    extendOPTPartition "${NAMNGUYE_DISK}" "${NAMNGUYE_MOUNT_ON}" "${MOUNT_HD_PARTITION_NUMBER}"

    # Install Apps

    "${appPath}/../../../../essential.bash" 'colin-itc'
    "${appPath}/../../../../../cookbooks/node-js/recipes/install.bash" "${NAMNGUYE_NODE_JS_VERSION}" "${NAMNGUYE_NODE_JS_INSTALL_FOLDER}"

    # Config SSH and GIT

    addUserAuthorizedKey "$(whoami)" "$(whoami)" "$(cat "${appPath}/../files/default/authorized_keys")"
    addUserSSHKnownHost "$(whoami)" "$(whoami)" "$(cat "${appPath}/../files/default/known_hosts")"

    configUserGIT "$(whoami)" "${NAMNGUYE_GIT_USER_NAME}" "${NAMNGUYE_GIT_USER_EMAIL}"
    generateUserSSHKey "$(whoami)"

    # Clean Up

    cleanUpSystemFolders
    cleanUpITMess

    # Display Notice

    displayNotice "$(whoami)"
}

main "${@}"