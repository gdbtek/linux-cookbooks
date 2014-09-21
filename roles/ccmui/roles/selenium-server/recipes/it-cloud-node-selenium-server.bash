#!/bin/bash -e

function main()
{
    local appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../../../cookbooks/mount-hd/attributes/default.bash"
    source "${appPath}/../../../../../libraries/util.bash"
    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/node.bash"

    extendOPTPartition "${ccmuiSeleniumServerDisk}" "${ccmuiSeleniumServerMountOn}" "${mounthdPartitionNumber}"

    "${appPath}/../../../../essential.bash"
    "${appPath}/../../../../../cookbooks/selenium-server/recipes/install-node.bash" "${ccmuiSeleniumServerHubHost}"

    # Clean Up and Config SSH

    cleanUp
    addUserAuthorizedKey "$(whoami)" "$(whoami)" "$(cat "${appPath}/../files/default/authorized_keys")"
}

main "${@}"