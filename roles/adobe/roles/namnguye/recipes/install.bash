#!/bin/bash -e

function main()
{
    # Load Libraries

    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../../../cookbooks/mount-hd/attributes/default.bash"
    source "${appPath}/../../../../../libraries/util.bash"
    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    # Extend HD

    extendOPTPartition "${namnguyeDisk:?}" "${namnguyeMountOn:?}" "${mounthdPartitionNumber:?}"

    # Install Apps

    "${appPath}/../../../../essential.bash" 'nam-itc'
    "${appPath}/../../../../../cookbooks/aws-cli/recipes/install.bash"
    "${appPath}/../../../../../cookbooks/chef/recipes/install.bash"
    "${appPath}/../../../../../cookbooks/node-js/recipes/install.bash" "${namnguyeNodeJSVersion:?}" "${namnguyeNodeJSInstallFolder:?}"
    "${appPath}/../../../../../cookbooks/packer/recipes/install.bash"
    "${appPath}/../../../../../cookbooks/shell-check/recipes/install.bash"

    # Config SSH and GIT

    addUserAuthorizedKey "$(whoami)" "$(whoami)" "$(cat "${appPath}/../files/default/authorized_keys")"
    addUserSSHKnownHost "$(whoami)" "$(whoami)" "$(cat "${appPath}/../files/default/known_hosts")"

    configUserGIT "$(whoami)" "${namnguyeGITUserName:?}" "${namnguyeGITUserEmail:?}"
    generateUserSSHKey "$(whoami)"

    # Clean Up

    cleanUpSystemFolders
    cleanUpITMess

    # Display Notice

    displayNotice "$(whoami)"
}

main "${@}"
