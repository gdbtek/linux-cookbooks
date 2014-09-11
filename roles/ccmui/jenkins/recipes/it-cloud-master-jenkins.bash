#!/bin/bash -e

function main()
{
    local appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../../lib/util.bash"
    source "${appPath}/../lib/util.bash"

    source "${appPath}/../../cookbooks/mount-hd/attributes/default.bash"
    source "${appPath}/../../cookbooks/tomcat/attributes/default.bash"

    source "${appPath}/../attributes/master.bash"

    extendOPTPartition "${ccmuiJenkinsDisk}" "${ccmuiJenkinsMountOn}" "${mounthdPartitionNumber}"

    "${appPath}/../essential.bash"
    "${appPath}/../../cookbooks/node-js/recipes/install.bash"
    "${appPath}/../../cookbooks/jenkins/recipes/install-master.bash"
    "${appPath}/../../cookbooks/ps1/recipes/install.bash" "${tomcatUserName}"
    "${appPath}/../../cookbooks/nginx/recipes/install.bash"

    cleanUp
    addUserAuthorizedKey "${tomcatUserName}" "${tomcatGroupName}" "$(cat "${appPath}/../files/default/authorized_keys")"
    addUserSSHKnownHost "${tomcatUserName}" "${tomcatGroupName}" "$(cat "${appPath}/../files/default/known_hosts")"
    displayNotice "${tomcatUserName}"
}

main "${@}"