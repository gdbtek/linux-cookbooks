#!/bin/bash -e

function main()
{
    # Load Libraries

    local appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../../../cookbooks/mount-hd/attributes/default.bash"
    source "${appPath}/../../../../../libraries/util.bash"
    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    # Extend HD

    extendOPTPartition "${ccmuiNamDisk}" "${ccmuiNamMountOn}" "${mounthdPartitionNumber}"

    # Install Apps

    "${appPath}/../../../../essential.bash"
    "${appPath}/../../../../../cookbooks/aws-cli/recipes/install.bash"
    "${appPath}/../../../../../cookbooks/chef/recipes/install.bash"
    "${appPath}/../../../../../cookbooks/jdk/recipes/install.bash"
    "${appPath}/../../../../../cookbooks/maven/recipes/install.bash"
    "${appPath}/../../../../../cookbooks/node-js/recipes/install.bash"
    "${appPath}/../../../../../cookbooks/packer/recipes/install.bash"
    "${appPath}/../../../../../cookbooks/ruby/recipes/install.bash"
    "${appPath}/../../../../../cookbooks/shell-check/recipes/install.bash"

    # Config SSH and GIT

    addUserAuthorizedKey "$(whoami)" "$(whoami)" "$(cat "${appPath}/../files/default/authorized_keys")"
    addUserSSHKnownHost "$(whoami)" "$(whoami)" "$(cat "${appPath}/../files/default/known_hosts")"

    configUserGIT "$(whoami)" "${ccmuiNamGITUserName}" "${ccmuiNamGITUserEmail}"
    generateUserSSHKey "$(whoami)"

    # Clean Up

    cleanUpSystemFolders
    cleanUpITMess

    # Display Notice

    displayNotice "$(whoami)"
}

main "${@}"