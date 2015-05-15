#!/bin/bash -e

function main()
{
    local -r hubHost="${1}"

    # Load Libraries

    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../../../../../cookbooks/mount-hd/attributes/default.bash"
    source "${appPath}/../../../../../../../libraries/util.bash"
    source "${appPath}/../../../../../libraries/util.bash"
    source "${appPath}/../attributes/node.bash"

    # Override Default

    if [[ "$(isEmptyString "${hubHost}")" = 'false' ]]
    then
        ccmuiSeleniumServerHubHost="${hubHost}"
    fi

    checkNonEmptyString "${ccmuiSeleniumServerHubHost}" 'undefined hub host'

    # Extend HD

    extendOPTPartition "${ccmuiSeleniumServerDisk}" "${ccmuiSeleniumServerMountOn}" "${mounthdPartitionNumber}"

    # Install Apps

    "${appPath}/../../../../../../essential.bash" 'selenium-linux-XXX.ccmui.adobe.com'
    "${appPath}/../../../../../../../cookbooks/selenium-server/recipes/install-node.bash" "${ccmuiSeleniumServerHubHost}"

    # Config SSH

    addUserAuthorizedKey "$(whoami)" "$(whoami)" "$(cat "${appPath}/../files/default/authorized_keys")"

    # Clean Up

    cleanUpSystemFolders
    cleanUpITMess
}

main "${@}"