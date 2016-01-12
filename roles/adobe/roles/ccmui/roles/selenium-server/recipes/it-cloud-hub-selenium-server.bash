#!/bin/bash -e

function main()
{
    # Load Libraries

    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../../../../../libraries/util.bash"
    source "${appFolderPath}/../../../../../libraries/util.bash"
    source "${appFolderPath}/../attributes/hub.bash"

    # Clean Up

    remountTMP
    resetLogs

    # Extend HD

    "${appFolderPath}/../../../../../../../cookbooks/mount-hd/recipes/extend.bash" "${CCMUI_SELENIUM_SERVER_DISK}" "${CCMUI_SELENIUM_SERVER_MOUNT_ON}"

    # Install Apps

    "${appFolderPath}/../../../../../../essential.bash" 'selenium.ccmui.adobe.com'
    "${appFolderPath}/../../../../../../../cookbooks/selenium-server/recipes/install-hub.bash"

    # Config SSH

    addUserAuthorizedKey "$(whoami)" "$(whoami)" "$(cat "${appFolderPath}/../files/authorized_keys")"

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