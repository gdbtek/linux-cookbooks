#!/bin/bash -e

function main()
{
    # Load Libraries

    local appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../../../cookbooks/mount-hd/attributes/default.bash"
    source "${appPath}/../../../../../libraries/util.bash"
    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/hub.bash"

    # Extend HD

    extendOPTPartition "${ccmuiSeleniumServerDisk}" "${ccmuiSeleniumServerMountOn}" "${mounthdPartitionNumber}"

    # Install Role

    "${appPath}/../../../../essential.bash"
    "${appPath}/../../../../../cookbooks/selenium-server/recipes/install-hub.bash"

    # Clean Up and Config SSH

    cleanUp
    addUserAuthorizedKey "$(whoami)" "$(whoami)" "$(cat "${appPath}/../files/default/authorized_keys")"
}

main "${@}"