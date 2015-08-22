#!/bin/bash -e

function main()
{
    # Load Libraries

    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../../../../../libraries/util.bash"
    source "${appPath}/../../../../../libraries/util.bash"
    source "${appPath}/../attributes/hub.bash"

    # Clean Up

    resetLogs

    # Extend HD

    "${appPath}/../../../../../../../cookbooks/mount-hd/recipes/extend.bash" "${CCMUI_SELENIUM_SERVER_DISK}" "${CCMUI_SELENIUM_SERVER_MOUNT_ON}"

    # Install Apps

    "${appPath}/../../../../../../essential.bash" 'selenium.ccmui.adobe.com'
    "${appPath}/../../../../../../../cookbooks/selenium-server/recipes/install-hub.bash"

    # Config SSH

    addUserAuthorizedKey "$(whoami)" "$(whoami)" "$(cat "${appPath}/../files/default/authorized_keys")"

    # Config Hosts

    local host=''

    for host in "${CCMUI_SELENIUM_SERVER_HOSTS[@]}"
    do
        header "ADDING HOST '${host}' to '/etc/hosts'"
        appendToFileIfNotFound '/etc/hosts' "${host}" "${host}" 'false' 'false' 'false'
    done

    # Clean Up

    cleanUpSystemFolders
    cleanUpITMess
}

main "${@}"