#!/bin/bash -e

function main()
{
    # Load Libraries

    local appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../../../cookbooks/jenkins/attributes/slave.bash"
    source "${appPath}/../../../../../cookbooks/mount-hd/attributes/default.bash"
    source "${appPath}/../../../../../libraries/util.bash"
    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/slave.bash"

    # Extend HD

    extendOPTPartition "${ccmuiJenkinsDisk}" "${ccmuiJenkinsMountOn}" "${mounthdPartitionNumber}"

    # Install Role

    "${appPath}/../../../../essential.bash"
    "${appPath}/../../../../../cookbooks/maven/recipes/install.bash"
    "${appPath}/../../../../../cookbooks/node-js/recipes/install.bash"
    "${appPath}/../../../../../cookbooks/jenkins/recipes/install-slave.bash"
    "${appPath}/../../../../../cookbooks/ps1/recipes/install.bash" "${jenkinsUserName}"

    # Config SSH and GIT

    cleanUp

    addUserAuthorizedKey "$(whoami)" "$(whoami)" "$(cat "${appPath}/../files/default/authorized_keys")"
    addUserSSHKnownHost "${jenkinsUserName}" "${jenkinsGroupName}" "$(cat "${appPath}/../files/default/known_hosts")"

    configUserGIT "${jenkinsUserName}" "${ccmuiJenkinsGITUserName}" "${ccmuiJenkinsGITUserEmail}"
    generateUserSSHKey "${jenkinsUserName}"

    # Display Notice

    displayNotice "${jenkinsUserName}"
}

main "${@}"