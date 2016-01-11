#!/bin/bash -e

function main()
{
    # Load Libraries

    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../../../../../libraries/util.bash"
    source "${appPath}/../../../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    # Clean Up

    remountTMP
    resetLogs

    # Extend HD

    "${appPath}/../../../../../../../cookbooks/mount-hd/recipes/extend.bash" "${CCMUI_FEATURE_FLIPPER_DISK}" "${CCMUI_FEATURE_FLIPPER_MOUNT_ON}"

    # Install Apps

    "${appPath}/../../../../../../essential.bash" 'ops.ccmui.adobe.com'
    "${appPath}/../../../../../../../cookbooks/mongodb/recipes/install.bash"
    "${appPath}/../../../../../../../cookbooks/node-js/recipes/install.bash" "${CCMUI_FEATURE_FLIPPER_NODE_JS_VERSION}" "${CCMUI_FEATURE_FLIPPER_NODE_JS_INSTALL_FOLDER}"

    # Config SSH and GIT

    addUserAuthorizedKey "$(whoami)" "$(whoami)" "$(cat "${appPath}/../files/authorized_keys")"
    addUserSSHKnownHost "$(whoami)" "$(whoami)" "$(cat "${appPath}/../files/known_hosts")"

    configUserGIT "$(whoami)" "${CCMUI_FEATURE_FLIPPER_GIT_USER_NAME}" "${CCMUI_FEATURE_FLIPPER_GIT_USER_EMAIL}"
    generateUserSSHKey "$(whoami)"

    # Clean Up

    cleanUpSystemFolders
    cleanUpITMess

    # Display Notice

    displayNotice "$(whoami)"
}

main "${@}"