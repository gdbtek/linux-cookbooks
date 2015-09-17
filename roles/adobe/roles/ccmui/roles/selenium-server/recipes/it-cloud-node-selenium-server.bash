#!/bin/bash -e

function main()
{
    local -r hubHost="${1}"

    # Load Libraries

    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../../../../../libraries/util.bash"
    source "${appPath}/../../../../../libraries/util.bash"
    source "${appPath}/../attributes/node.bash"

    # Override Default

    if [[ "$(isEmptyString "${hubHost}")" = 'false' ]]
    then
        CCMUI_SELENIUM_SERVER_HUB_HOST="${hubHost}"
    fi

    checkNonEmptyString "${CCMUI_SELENIUM_SERVER_HUB_HOST}" 'undefined hub host'

    # Clean Up

    resetLogs

    # Extend HD

    "${appPath}/../../../../../../../cookbooks/mount-hd/recipes/extend.bash" "${CCMUI_SELENIUM_SERVER_DISK}" "${CCMUI_SELENIUM_SERVER_MOUNT_ON}"

    # Install Apps

    "${appPath}/../../../../../../essential.bash" 'selenium-linux-XXX.ccmui.adobe.com'
    "${appPath}/../../../../../../../cookbooks/selenium-server/recipes/install-node.bash" "${CCMUI_SELENIUM_SERVER_HUB_HOST}"

    # Config SSH

    addUserAuthorizedKey "$(whoami)" "$(whoami)" "$(cat "${appPath}/../files/authorized_keys")"

    # Clean Up

    cleanUpSystemFolders
    cleanUpITMess
}

main "${@}"