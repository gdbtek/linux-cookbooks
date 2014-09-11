#!/bin/bash -e

function main()
{
    local appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../../lib/util.bash"
    source "${appPath}/../lib/util.bash"

    source "${appPath}/../../../../cookbooks/mount-hd/attributes/default.bash"
    source "${appPath}/../../../../cookbooks/jenkins/attributes/master.bash"

    source "${appPath}/../attributes/master.bash"

    extendOPTPartition "${ccmuiJenkinsDisk}" "${ccmuiJenkinsMountOn}" "${mounthdPartitionNumber}"

    "${appPath}/../../../essential.bash"
    "${appPath}/../../../../cookbooks/node-js/recipes/install.bash"
    "${appPath}/../../../../cookbooks/jenkins/recipes/install-master.bash"
    "${appPath}/../../../../cookbooks/ps1/recipes/install.bash" "${jenkinsUserName}"
    "${appPath}/../../../../cookbooks/nginx/recipes/install.bash"

    cleanUp

    addUserAuthorizedKey "${jenkinsUserName}" "${jenkinsGroupName}" "$(cat "${appPath}/../files/default/authorized_keys")"
    addUserSSHKnownHost "${jenkinsUserName}" "${jenkinsGroupName}" "$(cat "${appPath}/../files/default/known_hosts")"

    configUserGIT "${jenkinsUserName}" "${ccmuiJenkinsGITUserName}" "${ccmuiJenkinsGITUserEmail}"
    generateUserSSHKey "${jenkinsUserName}"

    displayNotice "${jenkinsUserName}"
}

main "${@}"