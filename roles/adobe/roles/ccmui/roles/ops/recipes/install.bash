#!/bin/bash -e

function main()
{
    # Load Libraries

    local appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../../../../../cookbooks/mount-hd/attributes/default.bash"
    source "${appPath}/../../../../../../../libraries/util.bash"
    source "${appPath}/../../../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    # Extend HD

    extendOPTPartition "${ccmuiOpsDisk}" "${ccmuiOpsMountOn}" "${mounthdPartitionNumber}"

    # Install Apps

    "${appPath}/../../../../../../essential.bash" 'ops.ccmui.adobe.com'
    "${appPath}/../../../../../../../cookbooks/mongodb/recipes/install.bash"
    "${appPath}/../../../../../../../cookbooks/node-js/recipes/install.bash" "${ccmuiOpsNodeJSVersion}" "${ccmuiOpsNodeJSInstallFolder}"

    # Config SSH and GIT

    addUserAuthorizedKey "$(whoami)" "$(whoami)" "$(cat "${appPath}/../files/default/authorized_keys")"
    addUserSSHKnownHost "$(whoami)" "$(whoami)" "$(cat "${appPath}/../files/default/known_hosts")"

    configUserGIT "$(whoami)" "${ccmuiOpsGITUserName}" "${ccmuiOpsGITUserEmail}"
    generateUserSSHKey "$(whoami)"

    # Clean Up

    cleanUpSystemFolders
    cleanUpITMess

    # Display Notice

    displayNotice "$(whoami)"
}

main "${@}"