#!/bin/bash -e

function main()
{
    local -r hubHost="${1}"

    # Load Libraries

    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../../../../../libraries/util.bash"
    source "${appFolderPath}/../../../../../libraries/util.bash"
    source "${appFolderPath}/../attributes/node.bash"

    # Override Default

    if [[ "$(isEmptyString "${hubHost}")" = 'false' ]]
    then
        CCMUI_SELENIUM_SERVER_HUB_HOST="${hubHost}"
    fi

    checkNonEmptyString "${CCMUI_SELENIUM_SERVER_HUB_HOST}" 'undefined hub host'

    # Clean Up

    remountTMP
    resetLogs

    # Extend HD

    "${appFolderPath}/../../../../../../../cookbooks/mount-hd/recipes/extend.bash" "${CCMUI_SELENIUM_SERVER_DISK}" "${CCMUI_SELENIUM_SERVER_MOUNT_ON}"

    # Install Apps

    "${appFolderPath}/../../../../../../essential.bash" 'selenium-linux-XXX.ccmui.adobe.com'
    "${appFolderPath}/../../../../../../../cookbooks/selenium-server/recipes/install-node.bash" "${CCMUI_SELENIUM_SERVER_HUB_HOST}"

    # Config SSH

    addUserAuthorizedKey "$(whoami)" "$(whoami)" "$(cat "${appFolderPath}/../files/authorized_keys")"

    # Clean Up

    cleanUpSystemFolders
    cleanUpITMess
}

main "${@}"