#!/bin/bash -e

function main()
{
    # Load Libraries

    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../../../../../libraries/util.bash"
    source "${appFolderPath}/../../../../../libraries/util.bash"
    source "${appFolderPath}/../attributes/default.bash"

    # Clean Up

    remountTMP
    resetLogs

    # Extend HD

    "${appFolderPath}/../../../../../../../cookbooks/mount-hd/recipes/extend.bash" "${CCMUI_OPS_DISK}" "${CCMUI_OPS_MOUNT_ON}"

    # Install Apps

    "${appFolderPath}/../../../../../../essential.bash" 'ops.ccmui.adobe.com'
    "${appFolderPath}/../../../../../../../cookbooks/mongodb/recipes/install.bash"
    "${appFolderPath}/../../../../../../../cookbooks/node-js/recipes/install.bash" "${CCMUI_OPS_NODE_JS_VERSION}" "${CCMUI_OPS_NODE_JS_INSTALL_FOLDER}"

    # Config SSH and GIT

    addUserAuthorizedKey "$(whoami)" "$(whoami)" "$(cat "${appFolderPath}/../files/authorized_keys")"
    addUserSSHKnownHost "$(whoami)" "$(whoami)" "$(cat "${appFolderPath}/../files/known_hosts")"

    configUserGIT "$(whoami)" "${CCMUI_OPS_GIT_USER_NAME}" "${CCMUI_OPS_GIT_USER_EMAIL}"
    generateUserSSHKey "$(whoami)"

    # Clean Up

    cleanUpSystemFolders
    cleanUpITMess

    # Display Notice

    displayNotice "$(whoami)"
}

main "${@}"